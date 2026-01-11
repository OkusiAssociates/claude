# Okusi Network Claude Code Deployment

Setup scripts for deploying Claude Code enterprise configuration across Okusi network servers.

See [parent README](../README.md#enterprise-configuration) for architecture details, CLAUDE.md hierarchy, settings system, and MCP integration.

## Architecture

**Two-Tier Model**:
- **Enterprise** (`/etc/claude-code/`) — Organization-wide policies and shared resources
- **User** (`~/.claude/`) — Per-user configuration, created automatically

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
  -i, --skip-install  Skip binary check
  -p, --skip-plugins  Skip marketplace cloning
  -m, --skip-mcp      Skip MCP configuration
  -C, --clobber       Overwrite existing config files
```

### Add User

```bash
sudo ./claude.add-user USERNAME [OPTIONS]

Options:
  --init-config       Initialize ~/.claude/ from template
  --copy-oauth PATH   Copy OAuth from specified .claude.json file
```

**What it does:**
1. Adds user to `claude-users` group
2. Optionally initializes `~/.claude/` from template (`--init-config`)
3. Optionally copies OAuth credentials (`--copy-oauth`)
4. Sets `installMethod=system` in `.claude.json` (prevents CLI warnings)
5. Creates `~/.local/bin/claude` symlink if `~/.local/bin/` exists

**Examples:**
```bash
# Basic (user authenticates themselves)
sudo ./claude.add-user biksu

# With pre-initialized config
sudo ./claude.add-user biksu --init-config

# With shared OAuth credentials
sudo ./claude.add-user biksu --copy-oauth /home/admin/.claude.json
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

---

**Version:** 1.1.0
**Last Updated:** 2026-01-11

#fin
