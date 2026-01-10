# CLAUDE.md File Hierarchy in Claude Code

This document explains how Claude Code handles CLAUDE.md files across different scopes.

---

## Overview

CLAUDE.md is Claude Code's **memory system** — it provides persistent context that Claude reads at the start of every conversation. This differs from `settings.json`, which controls *permissions and behavior*.

- **CLAUDE.md** = "What Claude should know" (context/memory)
- **settings.json** = "What Claude can do" (permissions/config)

---

## The 4-Level Hierarchy (Official)

Claude Code implements a hierarchical memory system with four primary levels:

| Priority | Memory Type | Location | Scope |
|----------|-------------|----------|-------|
| 1 (Highest) | **Enterprise Policy** | `/etc/claude-code/CLAUDE.md` (Linux) | All organization users |
| 2 | **Project Memory** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via git) |
| 3 | **Project Rules** | `./.claude/rules/*.md` | Team (via git) |
| 4 (Lowest) | **User Memory** | `~/.claude/CLAUDE.md` | Individual user |
| — | **Project Local** | `./CLAUDE.local.md` | Individual (gitignored) |

### File Paths by Operating System

**Linux/WSL:**
```
Enterprise:       /etc/claude-code/CLAUDE.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

**macOS:**
```
Enterprise:       /Library/Application Support/ClaudeCode/CLAUDE.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

**Windows:**
```
Enterprise:       C:\Program Files\ClaudeCode\CLAUDE.md
User:             ~/.claude/CLAUDE.md
User Rules:       ~/.claude/rules/*.md
Project:          ./CLAUDE.md or ./.claude/CLAUDE.md
Project Rules:    ./.claude/rules/*.md
Project Local:    ./CLAUDE.local.md
```

---

## Okusi Extensions

▲ The following are **Okusi-specific extensions** not in official Claude Code documentation:

### Enterprise Rules Directory

```
/etc/claude-code/.claude/rules/
├── bash-coding-standard.md
├── coding-principles.md
├── deployment.md
├── documentation.md
├── environment.md
├── git-commits.md
├── oknav.md
└── security.md
```

These modular enterprise rules are loaded with highest precedence and cannot be overridden.

---

## Discovery & Loading Order

### At Startup

Claude Code:

1. **Walks up the directory tree** from cwd to `/`, collecting any `CLAUDE.md` or `CLAUDE.local.md` files

2. **Loads files in precedence order** (highest → lowest):
   - Enterprise policy (if present) — cannot be overridden
   - Project memory (`./CLAUDE.md`)
   - Project rules (`./.claude/rules/*.md`)
   - User memory (`~/.claude/CLAUDE.md`)
   - User rules (`~/.claude/rules/*.md`)
   - Project local (`./CLAUDE.local.md`) — personal overrides

3. **Subtree discovery**: CLAUDE.md files in subdirectories are loaded *lazily* — only when Claude reads files in those directories

### Loading Example

When working in `/workspace/frontend/packages/ui/`, Claude Code loads:
1. `/workspace/CLAUDE.md` (workspace conventions)
2. `/workspace/frontend/CLAUDE.md` (frontend conventions)
3. `/workspace/frontend/packages/ui/CLAUDE.md` (UI-specific)
4. `~/.claude/CLAUDE.md` (personal preferences)

---

## Precedence Rules

Higher-priority scopes override lower-priority ones:

```
Enterprise Policy     ← Highest (cannot be overridden)
    ↓
Project Memory        ← Team shared
    ↓
Project Rules         ← Modular team rules
    ↓
User Memory           ← Personal defaults
    ↓
User Rules            ← Personal modular rules
    ↓
Project Local         ← Personal project overrides
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

### User Memory (`~/.claude/CLAUDE.md`)
- Personal preferences across ALL projects
- Code styling preferences
- Personal tooling shortcuts
- Individual workflow guidelines

### User Rules (`~/.claude/rules/*.md`)
- Modular personal rules for all projects
- Organized by topic (e.g., `preferences.md`, `workflows.md`)
- Lower precedence than project rules

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

Rules without a `paths` field are loaded unconditionally.

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
| Windows | `C:\ProgramData\ClaudeCode\` |

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
│ Ent. Policy   │ /etc/claude-code/CLAUDE.md         │ 1 (High) │ All users │
│ Ent. Rules ▲  │ /etc/claude-code/.claude/rules/    │ 1 (High) │ All users │
│ Project Mem   │ ./CLAUDE.md                        │ 2        │ Yes (git) │
│ Project Rules │ ./.claude/rules/*.md               │ 3        │ Yes (git) │
│ User Memory   │ ~/.claude/CLAUDE.md                │ 4 (Low)  │ No        │
│ User Rules    │ ~/.claude/rules/                   │ 4 (Low)  │ No        │
│ Project Local │ ./CLAUDE.local.md                  │ Override │ No        │
└───────────────┴────────────────────────────────────┴──────────┴───────────┘
▲ = Okusi custom extension
```

This hierarchy ensures enterprise policies are always enforced while allowing teams and individuals to customize their Claude Code experience.

---

## References

- [Claude Code Memory Docs](https://code.claude.com/docs/en/memory)
- [Claude Code Settings Docs](https://code.claude.com/docs/en/settings)

---

*Updated: 2026-01-11*
