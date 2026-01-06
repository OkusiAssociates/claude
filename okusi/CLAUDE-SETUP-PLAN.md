# Claude Code Global Setup for Okusi Network

## Configuration Structure (Key Understanding)

Claude Code uses **THREE SEPARATE** configuration mechanisms:

### 1. `~/.claude.json` (FILE)

A JSON **file** containing session state:

```
~/.claude.json
├── OAuth session tokens (authentication)
├── Preferences (theme, tips history)
├── mcpServers: {} (user-scope MCP servers)
├── Per-project state indexed by path:
│   └── "/ai/scripts/claude": { allowedTools, mcpServers, ... }
└── Caches
```

**For multi-user**: This file can be COPIED to all users on a machine after one person authenticates. All users then share the same OAuth session.

### 2. `~/.claude/` (DIRECTORY)

A **directory** for settings, prompts, and tools:

```
~/.claude/
├── settings.json       # Permission rules (Bash, Read, Write patterns)
├── CLAUDE.md           # Global system prompt
├── commands/           # Custom slash commands
├── agents/             # Custom subagents
├── skills/             # Skills
├── plugins/            # Installed plugins
├── projects/           # Conversation history
└── [runtime: plans/, todos/, debug/, etc.]
```

**For multi-user**: SYMLINK to shared location (`/usr/share/claude/.claude/`)

### 3. `/etc/claude-code/` (SYSTEM-WIDE)

Enterprise configuration (highest priority, cannot be overridden):

```
/etc/claude-code/
├── managed-settings.json    # Org-wide settings
└── managed-mcp.json         # Shared MCP servers for ALL users
```

**For shared MCP**: This is THE way to share MCP servers across all users.

---

## What You Want to Achieve

| Goal | Solution |
|------|----------|
| One installation per machine | `sudo npm install -g @anthropic-ai/claude-code` |
| Per-machine auth | One user authenticates, copy `~/.claude.json` to others |
| Shared settings/agents/skills | Symlink `~/.claude/` → `/usr/share/claude/.claude/` |
| Shared MCP servers | `/etc/claude-code/managed-mcp.json` |

---

## Current State (okusi machine)

**What's Working:**
- ✓ Shared directory at `/usr/share/claude/.claude/`
- ✓ Group `claude-users` exists (GID 5001)
- ✓ sysadmin has symlink `~/.claude -> /usr/share/claude/.claude`
- ✓ Commands, agents, settings are shared

**What's Missing:**
- ✗ Root user has no `~/.claude` symlink
- ✗ gary user not in group, no symlink
- ✗ No `/etc/claude-code/managed-mcp.json`
- ✗ Some files have 600 permissions instead of 660

**Dual Installation Issue:**
- System install: `/usr/lib/node_modules/@anthropic-ai/claude-code`
- User install: `~/.npm-global/lib/node_modules/@anthropic-ai/claude-code`
- Currently using USER install (should use system)

---

## Action Plan

### Phase 0: Copy Plan to okusi/

First action after exiting plan mode:
```bash
cp /home/sysadmin/.claude/plans/reflective-jumping-sunset.md /ai/scripts/claude/okusi/CLAUDE-SETUP-PLAN.md
```

### Phase 1: Scripts to Create

Create in `/ai/scripts/claude/okusi/`:

1. **`claude-setup-machine.sh`**
   - Install Claude Code globally (npm)
   - Create group `claude-users`
   - Create shared directory structure
   - Set up `/etc/claude-code/` for MCP

2. **`claude-add-user.sh`**
   - Add user to `claude-users` group
   - Create `~/.claude` symlink
   - Copy `~/.claude.json` from template

3. **`claude-fix-permissions.sh`**
   - Reset all file permissions to 664
   - Reset all directories to 2775 (setgid)

4. **`managed-mcp.json`**
   - Template for shared MCP servers

### Phase 2: Fix This Machine (okusi)

```bash
# 1. Remove user-level install
npm uninstall -g @anthropic-ai/claude-code

# 2. Fix permissions
sudo chmod 660 /usr/share/claude/.claude/.credentials.json
sudo chmod 660 /usr/share/claude/.claude/stats-cache.json
sudo chmod 2775 /usr/share/claude/.claude/plans/

# 3. Add gary to group
sudo usermod -a -G claude-users gary

# 4. Create missing symlinks
sudo ln -s /usr/share/claude/.claude /root/.claude
sudo ln -s /usr/share/claude/.claude /home/gary/.claude
sudo chown -h gary:gary /home/gary/.claude

# 5. Copy OAuth to other users
sudo cp ~/.claude.json /root/.claude.json
sudo cp ~/.claude.json /home/gary/.claude.json
sudo chown gary:gary /home/gary/.claude.json

# 6. Create MCP config
sudo mkdir -p /etc/claude-code
sudo cp okusi/managed-mcp.json /etc/claude-code/
```

### Phase 3: Deploy to Servers

For each server (ok1, ok2, ok3):
1. Run `claude-setup-machine.sh`
2. Run `claude-add-user.sh` for each user
3. One user authenticates via browser
4. Copy OAuth file to other users

---

## MCP Server Sharing

Create `/etc/claude-code/managed-mcp.json`:

```json
{
  "mcpServers": {
    "customkb": {
      "command": "uv",
      "args": ["run", "--directory", "/ai/scripts/customkb", "customkb-mcp"],
      "env": {}
    }
  }
}
```

This makes the MCP server available to ALL users on the machine without any per-user configuration.

---

## Verification Checklist

```bash
# Installation
which claude                     # Should show /usr/local/bin or /usr/lib/...
claude --version                 # Works for all users

# Configuration
ls -la ~/.claude                 # Symlink to /usr/share/claude/.claude
ls -la ~/.claude.json            # File exists (OAuth)
groups                           # Includes claude-users

# Permissions
stat /usr/share/claude/.claude/  # 2775 drwxrwsr-x claude-users

# MCP
ls -la /etc/claude-code/         # managed-mcp.json exists
```

---

## Potential Issues

| Issue | Mitigation |
|-------|------------|
| Shared OAuth expires | Re-authenticate, re-copy to users |
| Shared conversation history | Accept (team trust model) |
| Updates need sudo | Always `sudo claude update` |
| File locking conflicts | Claude has internal locking |

---

## Sources

- [Claude Code Settings](https://code.claude.com/docs/en/settings)
- [Claude Code Setup](https://code.claude.com/docs/en/setup)
- [Multi-User Permissions](https://startaitools.com/posts/fixing-claude-code-eacces-multi-user-linux-permission-architecture/)
