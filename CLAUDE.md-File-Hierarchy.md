# CLAUDE.md File Hierarchy in Claude Code

This document explains how Claude Code handles CLAUDE.md files across different scopes.

---

## Overview

CLAUDE.md is Claude Code's **memory system** — it provides persistent context that Claude reads at the start of every conversation. This differs from `settings.json`, which controls *permissions and behavior*.

- **CLAUDE.md** = "What Claude should know" (context/memory)
- **settings.json** = "What Claude can do" (permissions/config)

---

## The 5-Scope Hierarchy

Claude Code implements a hierarchical memory system with five distinct scopes:

| Scope | Location | Purpose | Shared? |
|-------|----------|---------|---------|
| **Enterprise** | `/etc/claude-code/CLAUDE.md` (Linux) | Organization-wide policies | All users |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you |
| **User Rules** | `~/.claude/rules/*.md` | Modular personal rules | Just you |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team (via git) |
| **Project Rules** | `./.claude/rules/*.md` | Topic-specific project rules | Team (via git) |
| **Project Local** | `./CLAUDE.local.md` | Personal project-specific prefs | Just you (gitignored) |

### File Paths by Operating System

**Linux/WSL:**
```
Enterprise:       /etc/claude-code/CLAUDE.md
Enterprise Rules: /etc/claude-code/.claude/rules/*.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

**macOS:**
```
Enterprise:       /Library/Application Support/ClaudeCode/CLAUDE.md
Enterprise Rules: /Library/Application Support/ClaudeCode/.claude/rules/*.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

**Windows:**
```
Enterprise:       C:\Program Files\ClaudeCode\CLAUDE.md
Enterprise Rules: C:\Program Files\ClaudeCode\.claude\rules\*.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

---

## Discovery & Loading Order

### At Startup

Claude Code:

1. **Walks up the directory tree** from cwd to `/`, collecting any `CLAUDE.md` or `CLAUDE.local.md` files

2. **Loads files in this order** (general → specific):
   - Enterprise policy (if present)
   - User memory (`~/.claude/CLAUDE.md`)
   - User rules (`~/.claude/rules/*.md`)
   - Project rules (`./.claude/rules/*.md`)
   - Project memory (`./CLAUDE.md`)
   - Project local (`./CLAUDE.local.md`)

3. **Subtree discovery**: CLAUDE.md files in subdirectories are loaded *lazily* — only when Claude reads files in those directories

---

## Precedence Rules

More specific scopes override more general ones:

```
Enterprise Policy     ← Highest (cannot be overridden)
    ↓
Project Local         ← Your personal project prefs
    ↓
Project Memory        ← Team shared
    ↓
Project Rules         ← Modular team rules
    ↓
User Rules            ← Your personal rules
    ↓
User Memory           ← Lowest priority
```

**Example:** If `~/.claude/CLAUDE.md` says "use tabs" but `./CLAUDE.md` says "use spaces", the project instruction wins.

---

## Scope Purposes

### Enterprise Policy (`/etc/claude-code/CLAUDE.md`)
- Organization-wide instructions managed by IT/DevOps
- Company coding standards
- Security policies and compliance requirements
- Deployed via configuration management (MDM, Ansible, etc.)
- **Cannot be overridden by other scopes**

### Enterprise Rules (`/etc/claude-code/.claude/rules/*.md`)
- Modular organization-wide rules (same format as user/project rules)
- Organized by topic for maintainability
- Loaded with highest precedence (cannot be overridden)
- Example structure:
  ```
  /etc/claude-code/.claude/rules/
  ├── bash-coding-standard.md
  ├── coding-principles.md
  ├── documentation.md
  ├── environment.md
  ├── git-commits.md
  └── oknav.md
  ```

### User Memory (`~/.claude/CLAUDE.md`)
- Personal preferences across ALL projects
- Code styling preferences
- Personal tooling shortcuts
- Individual workflow guidelines

### User Rules (`~/.claude/rules/*.md`)
- Modular personal rules for all projects
- Organized by topic (e.g., `preferences.md`, `workflows.md`)
- Loaded before project rules (lower precedence)

### Project Memory (`./CLAUDE.md` or `./.claude/CLAUDE.md`)
- Team-shared instructions in version control
- Project architecture documentation
- Coding standards for the project
- Common workflows

### Project Rules (`./.claude/rules/*.md`)
- Modular, topic-specific project instructions
- Language guidelines (e.g., `rules/typescript.md`)
- Testing conventions (e.g., `rules/testing.md`)
- Supports subdirectory organization

### Project Local Memory (`./CLAUDE.local.md`)
- Personal project-specific preferences
- Your sandbox URLs, test data, machine-specific settings
- **Automatically added to `.gitignore`**

---

## Special Features

### Path-Specific Rules (Conditional Loading)

Rules in `.claude/rules/` can target specific files using YAML frontmatter:

```markdown
---
paths: src/api/**/*.ts
---

# API Development Rules
- All API endpoints must include input validation
- Use the standard error response format
```

Supported glob patterns:
- `**/*.ts` — All TypeScript files
- `src/**/*` — All files under src/
- `src/components/*.tsx` — Components in specific directory
- `{src,lib}/**/*.ts` — Multiple patterns with braces

### Import Syntax

CLAUDE.md files can import other files using `@path` syntax:

```markdown
See @README for project overview.
Follow @docs/coding-standards.md for style.
Personal prefs: @~/.claude/my-project-instructions.md
```

Features:
- Supports relative and absolute paths
- Max depth: 5 hops (prevents infinite recursion)
- Ignored inside code blocks: `` `@anthropic-ai/claude-code` ``
- Useful for sharing instructions across git worktrees

### Automatic Gitignore

`CLAUDE.local.md` is **automatically added to `.gitignore`** when created — designed for personal preferences that shouldn't be committed.

### Rules Directory Organization

```
.claude/rules/
├── frontend/
│   ├── react.md
│   └── styles.md
├── backend/
│   ├── api.md
│   └── database.md
├── testing.md
└── security.md
```

All `.md` files are discovered recursively. Symlinks are fully supported for sharing common rules across projects.

---

## Useful Commands

| Command | Purpose |
|---------|---------|
| `/init` | Bootstrap a new project CLAUDE.md with codebase documentation |
| `/memory` | View loaded memory files and edit them directly |

---

## CLAUDE.md vs settings.json

These are complementary but distinct systems:

| Aspect | CLAUDE.md | settings.json |
|--------|-----------|---------------|
| **Content** | Instructions, context, rules | Permissions, hooks, model config |
| **Format** | Markdown (human-friendly) | JSON (structured config) |
| **Purpose** | "What Claude should know" | "What Claude can do" |

### settings.json Locations

- **User**: `~/.claude/settings.json`
- **Project**: `.claude/settings.json`
- **Project Local**: `.claude/settings.local.json` (gitignored)
- **Enterprise**: `managed-settings.json` in system directories

---

## Enterprise Managed Configuration

Organizations can deploy system-wide configuration files that cannot be overridden by users.

### Managed Configuration Files

| File | Purpose |
|------|---------|
| `managed-settings.json` | System-wide settings (permissions, behavior) |
| `managed-mcp.json` | Organization-wide MCP server definitions |

### File Locations by OS

| OS | Directory |
|----|-----------|
| Linux/WSL | `/etc/claude-code/` |
| macOS | `/Library/Application Support/ClaudeCode/` |
| Windows | `C:\Program Files\ClaudeCode\` |

### managed-mcp.json Example

```json
{
  "mcpServers": {
    "yatti": {
      "command": "uv",
      "args": ["run", "--directory", "/ai/scripts/yatti-api-mcp", "python", "-m", "mcp_server.server"],
      "env": {}
    }
  }
}
```

### MCP Allowlist/Denylist

Enterprise administrators can control which MCP servers are permitted:

```json
{
  "allowedMcpServers": ["yatti", "filesystem"],
  "deniedMcpServers": ["untrusted-server"]
}
```

- `allowedMcpServers`: Only these servers can be used (whitelist mode)
- `deniedMcpServers`: These servers are blocked (blacklist mode)

---

## Summary Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│              CLAUDE.MD SCOPE SUMMARY & PRECEDENCE                         │
├───────────────┬────────────────────────────────────┬──────────┬───────────┤
│ Scope         │ File Path                          │ Priority │ Shared?   │
├───────────────┼────────────────────────────────────┼──────────┼───────────┤
│ Ent. Policy   │ /etc/claude-code/CLAUDE.md         │ Highest  │ All users │
│ Ent. Rules    │ /etc/claude-code/.claude/rules/    │ Highest  │ All users │
│ Project Local │ ./CLAUDE.local.md                  │ High     │ No        │
│ Project Mem   │ ./CLAUDE.md                        │ Medium   │ Yes (git) │
│ Project Rules │ ./.claude/rules/*.md               │ Medium   │ Yes (git) │
│ User Rules    │ ~/.claude/rules/                   │ Low      │ No        │
│ User Memory   │ ~/.claude/CLAUDE.md                │ Lowest   │ No        │
└───────────────┴────────────────────────────────────┴──────────┴───────────┘
```

This hierarchy ensures enterprise policies are always enforced while allowing teams and individuals to customize their Claude Code experience.

---

*Generated: 2025-12-28*
