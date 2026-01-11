# Okusi Network Claude Code Deployment

Setup scripts for deploying Claude Code enterprise configuration across Okusi network servers.

## Architecture

**Two-Tier Model**:
1. **Enterprise** (`/etc/claude-code/`) — Organization-wide policies and shared resources
2. **User** (`~/.claude/`) — Per-user configuration, created automatically

```
/etc/claude-code/                    # Enterprise (all users)
├── CLAUDE.md                        # Enterprise policies (highest priority)
├── managed-mcp.json                 # MCP server configuration
└── .claude/
    ├── agents/                      # Shared agent definitions
    ├── commands/                    # Shared commands
    ├── rules/                       # Enterprise rules (enforced)
    └── plugins/                     # Shared plugin marketplaces

~/.claude/                           # User (per-user, auto-created)
├── CLAUDE.md                        # User preferences
├── settings.json                    # User settings
├── rules/                           # User rules
└── ...
```

## Servers Deployed

| Server | Claude | uv | MCP | Status |
|--------|--------|-----|-----|--------|
| ok0 (okusi) | latest | 0.9.x | customkb | ✓ |
| ok1 (okusi1) | latest | 0.9.x | customkb | ✓ |
| okusi2 | latest | 0.9.x | customkb | ✓ |
| okusi3 | latest | 0.9.x | customkb | ✓ |
| ok0-batam | latest | 0.9.x | customkb | ✓ |

## Setup Scripts

| Script | Version | Purpose |
|--------|---------|---------|
| `claude.setup-machine` | 1.5.0 | Enterprise setup (groups, dirs, templates, MCP) |
| `claude.add-user` | 1.5.0 | Add user to claude-users group |

**Utilities** (in parent directory):
| Script | Version | Purpose |
|--------|---------|---------|
| `claude.fix-permissions` | 1.4.0 | Reset permissions on enterprise or user directories |
| `claude.cascade` | 1.2.0 | Display CLAUDE.md hierarchy |

## Templates

| Template | Deploys To |
|----------|------------|
| `.claude.template-enterprise/` | `/etc/claude-code/.claude/` |
| `.claude.template-user/` | `~/.claude/` (via `--init-config`) |
| `CLAUDE.md.enterprise.template` | `/etc/claude-code/CLAUDE.md` |
| `settings.json.template` | Reference for user settings |
| `managed-mcp.json.template` | `/etc/claude-code/managed-mcp.json` |

## Key Configuration

**Group**: `claude-users` (GID 1337 on all servers)

**Enterprise Permissions** (`/etc/claude-code/`):
- Directories: `2775` (rwxrwsr-x) with setgid
- Files: `664` (rw-rw-r--)
- Owner: `root:claude-users`

**User Permissions** (`~/.claude/`):
- Directories: `755` (rwxr-xr-x)
- Files: `644` (rw-r--r--)
- Credentials: `600`
- Owner: `USER:PRIMARY_GROUP`

**MCP Server** (`/etc/claude-code/managed-mcp.json`):
```json
{
  "mcpServers": {
    "customkb": {
      "command": "uv",
      "args": ["run", "--directory", "/ai/scripts/customkb", "python", "-m", "mcp_server.server"],
      "env": {}
    }
  }
}
```

## Deployment

### Enterprise Setup on New Server

```bash
# Sync scripts to server
rsync -av /ai/scripts/claude/okusi/ SERVER:/ai/scripts/claude/okusi/

# Run enterprise setup
ssh SERVER 'sudo /ai/scripts/claude/okusi/claude.setup-machine'
```

### Setup Script Options

```bash
sudo ./claude.setup-machine [OPTIONS]

Options:
  -h, --help          Show help
  -V, --version       Show version
  -i, --skip-install  Skip npm installation
  -p, --skip-plugins  Skip marketplace cloning
  -m, --skip-mcp      Skip MCP configuration
  -C, --clobber       Overwrite existing config files
```

### Add User

```bash
# Basic (user's ~/.claude/ created when they run claude)
sudo ./claude.add-user USERNAME

# With pre-initialized config from template
sudo ./claude.add-user USERNAME --init-config

# With shared OAuth credentials
sudo ./claude.add-user USERNAME --copy-oauth /home/admin/.claude.json
```

### Fix Permissions

```bash
# Fix enterprise directory
sudo ./claude.fix-permissions

# Fix specific user's directory
sudo ./claude.fix-permissions --user USERNAME

# Dry run (show what would be done)
sudo ./claude.fix-permissions --dry-run
```

## Post-Setup

1. **First user authenticates**: Run `claude` and complete OAuth flow
2. **Optionally copy credentials** to other users:
   ```bash
   sudo ./claude.add-user USERNAME --copy-oauth ~/.claude.json
   ```
3. **Verify setup**: Run `claude.cascade` to view the CLAUDE.md hierarchy
4. **Check MCP**: In claude, run `/mcp` to verify server connection

## Syncing Updates

To sync updated scripts to all servers:

```bash
for server in ok0 ok1 okusi2 okusi3; do
  rsync -av /ai/scripts/claude/okusi/ "$server:/ai/scripts/claude/okusi/"
done
```

## Troubleshooting

### Permission Denied Errors

```bash
# Fix enterprise permissions
sudo ./claude.fix-permissions

# Fix user permissions
sudo ./claude.fix-permissions --user USERNAME
```

### MCP Server Not Connecting

1. Verify uv is installed: `uv --version`
2. Check customkb exists: `ls /ai/scripts/customkb`
3. Test MCP server: `timeout 3 uv run --directory /ai/scripts/customkb python -m mcp_server.server`
4. Add mcp dependency if missing: `cd /ai/scripts/customkb && uv add mcp`

### Legacy Symlink Warning

If `claude.add-user` warns about a legacy symlink:
```bash
# Remove old symlink (user will get own ~/.claude/ when they run claude)
rm ~/.claude
```

### View CLAUDE.md Hierarchy

```bash
claude.cascade
```

#fin
