# Claude Code Utilities

A comprehensive toolkit for extending and customizing Claude Code CLI with advanced features including agent templates, project initialization, and SDK examples.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Enterprise Configuration](#enterprise-configuration)
- [CLAUDE.md Hierarchy](#claudemd-hierarchy)
- [Settings System](#settings-system)
- [MCP Integration](#mcp-integration)
- [Plugin Ecosystem](#plugin-ecosystem)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Scripts](#core-scripts)
  - [claude.x](#claudex)
  - [claude.init](#claudeinit)
  - [claude.update](#claudeupdate)
  - [claude.cascade](#claudecascade)
- [Agent System](#agent-system)
- [SDK Examples](#sdk-examples)
- [Skills System](#skills-system)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Enterprise Standards](#enterprise-standards)
- [Troubleshooting](#troubleshooting)

## Overview

This repository provides a suite of wrapper scripts and utilities for Claude Code CLI that enable:
- **Agent Templates** - Load specialized AI personas with custom system prompts and knowledge bases
- **Dangerous Mode** - Pre-configured permissions for unrestricted file operations
- **Project Initialization** - Streamlined setup with canonical configurations
- **SDK Integration** - Python examples demonstrating programmatic Claude access
- **Skills System** - Documentation and examples for Claude Code skills development

## Features

◉ **Agent Template System** - Load specialized AI agents with custom system prompts and knowledge bases
◉ **Dangerous Mode Wrapper** - Pre-configured permissions for unrestricted file operations
◉ **BCS Integration** - Bash Coding Standard compliance awareness
◉ **SDK Examples** - Python examples demonstrating Claude Agent SDK usage
◉ **Auto-initialization** - Streamlined project setup with canonical configurations
◉ **Skills Framework** - Comprehensive documentation for building Claude Code skills
◉ **Enterprise Configuration** - Multi-server deployment with centralized policy management
◉ **MCP Integration** - Custom knowledge base server with 14+ searchable domains

---

## Enterprise Configuration

Claude Code supports organization-wide configuration through the enterprise directory at `/etc/claude-code/`. This enables centralized policy management across all users and servers.

### Directory Structure

```
/etc/claude-code/
├── CLAUDE.md                    # Enterprise policies (cannot be overridden)
├── managed-mcp.json             # Enterprise MCP server configuration
└── .claude/
    ├── CLAUDE.md                # Index file for rules
    ├── rules/                   # Modular enterprise rules
    │   ├── bash-coding-standard.md
    │   ├── coding-principles.md
    │   ├── documentation.md
    │   ├── environment.md
    │   ├── git-commits.md
    │   └── oknav.md
    ├── commands/                # Shared command templates
    │   ├── audit-bash.md
    │   ├── audit-php.md
    │   ├── audit-python.md
    │   └── ...
    └── agents/                  # Shared agent templates
        ├── bash-expert.md
        ├── code-reviewer.md
        ├── documentation-writer.md
        └── python-expert.md
```

### Multi-Server Deployment

Sync enterprise configuration across Okusi servers using rsync:

```bash
# Sync to all servers
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi1:/etc/claude-code/
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi2:/etc/claude-code/
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi3:/etc/claude-code/
```

### Viewing Enterprise Policies

```bash
# View enterprise CLAUDE.md
cat /etc/claude-code/CLAUDE.md

# List enterprise rules
ls /etc/claude-code/.claude/rules/
```

---

## CLAUDE.md Hierarchy

Claude Code implements a 5-level hierarchical memory system. Files are loaded in order from lowest to highest priority, with higher priority instructions overriding lower ones.

### Load Order (Cascade)

```
┌─────────────────────────────────────────────────────────────────┐
│          CLAUDE.md SCOPE SUMMARY & PRECEDENCE                   │
├──────────────┬──────────────────────────────┬──────────┬────────┤
│ Scope        │ File Path                    │ Priority │ Shared │
├──────────────┼──────────────────────────────┼──────────┼────────┤
│ Enterprise   │ /etc/claude-code/CLAUDE.md   │ Highest  │ All    │
│ Project Loc  │ ./CLAUDE.local.md            │ High     │ No     │
│ Project Mem  │ ./CLAUDE.md                  │ Medium   │ Yes    │
│ Project Rules│ ./.claude/rules/*.md         │ Medium   │ Yes    │
│ User Rules   │ ~/.claude/rules/             │ Low      │ No     │
│ User Mem     │ ~/.claude/CLAUDE.md          │ Lowest   │ No     │
└──────────────┴──────────────────────────────┴──────────┴────────┘
```

### Scope Purposes

| Scope | Location | Purpose |
|-------|----------|---------|
| **Enterprise** | `/etc/claude-code/CLAUDE.md` | Organization-wide policies (security, compliance) |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences across all projects |
| **User Rules** | `~/.claude/rules/*.md` | Modular personal rules |
| **Project** | `./CLAUDE.md` | Team-shared project instructions (via git) |
| **Project Rules** | `./.claude/rules/*.md` | Topic-specific project rules |
| **Project Local** | `./CLAUDE.local.md` | Personal project-specific prefs (gitignored) |

### Viewing the Cascade

Use `claude.cascade` to visualize the current hierarchy:

```bash
# View cascade for current directory
claude.cascade

# View cascade for specific directory
claude.cascade /path/to/project
```

### Modular Rules System

Rules in `.claude/rules/` directories are automatically discovered and loaded. Use YAML frontmatter for path-specific rules:

```markdown
---
paths:
  - "**/*.sh"
  - "**/*.bash"
---

# Bash Coding Standard
These rules apply only to shell script files.
```

---

## Settings System

Claude Code uses a hierarchical settings system separate from CLAUDE.md memory files.

### Settings Locations

| Scope | File | Purpose |
|-------|------|---------|
| **Enterprise** | `/etc/claude-code/managed-settings.json` | Organization-wide settings |
| **User** | `~/.claude/settings.json` | Personal settings for all projects |
| **User Local** | `~/.claude/settings.local.json` | Machine-specific overrides |
| **Project** | `.claude/settings.json` | Project-shared settings |
| **Project Local** | `.claude/settings.local.json` | Personal project settings (gitignored) |

### Settings Structure

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash",
      "WebSearch",
      "Bash(ok0:*)",
      "Bash(ok1:*)",
      "Read(//etc/**)",
      "WebFetch(domain:github.com)"
    ],
    "deny": []
  },
  "model": "opus",
  "alwaysThinkingEnabled": true,
  "enabledPlugins": {
    "code-review@claude-code-plugins": true,
    "commit-commands@claude-code-plugins": true
  }
}
```

### Permission Patterns

- `Bash(command:*)` — Allow specific commands with any arguments
- `Read(//path/**)` — Allow reading files under path
- `WebFetch(domain:example.com)` — Allow fetching from specific domain

---

## MCP Integration

Claude Code integrates with Model Context Protocol (MCP) servers for extended functionality.

### Enterprise MCP Configuration

Managed MCP servers are configured in `/etc/claude-code/managed-mcp.json`:

```json
{
  "mcpServers": {
    "customkb": {
      "command": "uv",
      "args": ["run", "--directory", "/ai/scripts/customkb", "customkb"]
    }
  }
}
```

### Custom Knowledge Base Server (customkb)

The customkb MCP server provides vector search across 14+ specialized knowledge bases:

| Knowledge Base | Description |
|----------------|-------------|
| `appliedanthropology` | Human evolution, cultural development, secular dharma |
| `jakartapost` | Jakarta Post archive (1994-2005) |
| `okusiassociates` | Indonesian PMA company setup, corporate law |
| `okusimail` | Business inquiry patterns and responses |
| `okusiresearch` | Indonesian investment research |
| `ollama` | Ollama configuration and AI systems |
| `openai_docs` | OpenAI API documentation |
| `peraturan` | Indonesian laws and regulations |
| `prosocial` | Psychology-philosophy insights |
| `seculardharma` | Secular dharma philosophy |
| `smi` | SMI domain research |
| `uv` | Full-stack programming, AI systems |
| `wayang` | Indonesian wayang culture |

### Using Knowledge Base Search

```bash
# Within Claude session
mcp__customkb__search_okusiassociates "PMA company registration"
mcp__customkb__search_peraturan "Indonesian investment law"
mcp__customkb__list_knowledgebases
```

---

## Plugin Ecosystem

Claude Code supports plugins for extended functionality. Plugins are managed in `settings.json`.

### Installed Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| `agent-sdk-dev` | claude-code-plugins | Agent SDK development tools |
| `code-review` | claude-code-plugins | Code review automation |
| `commit-commands` | claude-code-plugins | Git commit helpers |
| `document-skills` | anthropic-agent-skills | Document creation (PDF, DOCX, PPTX) |
| `example-skills` | anthropic-agent-skills | Example skill implementations |
| `explanatory-output-style` | claude-code-plugins | Educational output formatting |
| `feature-dev` | claude-code-plugins | Feature development workflow |
| `frontend-design` | claude-code-plugins | Frontend design assistance |
| `hookify` | claude-code-plugins | Hook creation and management |
| `learning-output-style` | claude-code-plugins | Interactive learning mode |
| `plugin-dev` | claude-code-plugins | Plugin development tools |

### Managing Plugins

```json
// In ~/.claude/settings.json
{
  "enabledPlugins": {
    "code-review@claude-code-plugins": true,
    "commit-commands@claude-code-plugins": true,
    "hookify@claude-code-plugins": false
  }
}
```

### Plugin Locations

- **Official plugins**: `~/.claude/plugins/`
- **Plugin sources**: `claude-code-plugins`, `anthropic-agent-skills`

---

## Installation

### Prerequisites

- **Claude Code CLI** (native binary or npm)
- **Python 3.12+** (for SDK examples)
- **Node.js 22.x LTS** (optional, for npm installation)

### Quick Install

```bash
# Native binary installation (recommended)
curl -fsSL https://claude.ai/install.sh | bash
source ~/.bashrc
claude --version

# Alternative: npm installation
npm install -g @anthropic-ai/claude-code
```

For detailed installation instructions, see [claude-install.md](./claude-install.md).

## Quick Start

### Basic Usage

```bash
# Start Claude with dangerous permissions
./claude.x

# Start Claude with a specific agent template
./claude.x -T leet

# Initialize Claude in a new project directory
cd /path/to/project
/ai/scripts/claude/claude.init
```

### Using Agent Templates

```bash
# List available agents
dv2-agents list

# Load an agent template
./claude.x -T leet

# One-shot query with agent
./claude.x -T trans "Convert this bash script to Python"
```

## Core Scripts

### claude.x

Main wrapper script for Claude Code with enhanced permissions and agent support.

**Version:** 1.2.0
**Purpose:** Run Claude with 'dangerous' settings and optional Agent system prompts

**Usage:**
```bash
claude.x [OPTIONS] [PROMPT]
```

**Key Features:**
- Pre-configured with `--allowedTools Read Write Edit Bash`
- Permission mode: `acceptEdits`
- Dangerously skip permissions (auto-accept all operations)
- Agent template loading from Agents.json
- Multiple working directories support
- Smart conversation continuation:
  - Auto-detects existing conversations for current directory
  - If conversation exists: automatically continues
  - If no conversation exists: starts fresh
  - Override with `-n/--new` (always fresh) or `-c/--continue` (force continue)

**Options:**
- `-T AGENT` - Load agent template (e.g., leet, trans, sarki, draa)
- `-n, --new, --no-continue` - Start fresh conversation
- `-c, --continue` - Force continue previous conversation
- `-v, --verbose` - Increase verbosity (repeatable: -vv, -vvv)
- `-q, --quiet` - Suppress informational messages
- `-h, --help` - Show help message
- `-V, --version` - Show version information

**System Prompt Options:**
- `--system-prompt TEXT` - Replace default prompt (CLAUDE.md ignored)
- `--system-prompt-file FILE` - Replace default prompt from file
- `--append-system-prompt TEXT` - Append to default prompt (CLAUDE.md loaded)
- `--append-system-prompt-file FILE` - Append to default prompt from file

▲ **Note:** `--system-prompt` replaces the entire default system prompt and CLAUDE.md files are NOT loaded. Use `--append-system-prompt` to add instructions while preserving defaults.

**Default Directories:**
The script automatically adds these directories to Claude's context:
- `$HOME`
- `/tmp`
- `/ai`
- `/usr/local/`
- `/usr/share`

**Examples:**
```bash
# Basic usage
./claude.x

# Load specific agent
./claude.x -T leet

# Add additional context directories
./claude.x -T leet --add-dir /data

# One-shot query with agent
./claude.x -T trans "Translate this code to Python"

# Fresh conversation with verbose output
./claude.x --new -vv -T leet
```

**Exit Codes:**

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Agent not found, Agents.json not found, or missing systemprompt |
| 22 | Invalid option argument (EINVAL) |

**Environment Variables:**

- `AGENTS_JSON` - Override path to Agents.json
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` - Max output tokens (default: 32000, agent wrappers may set 64000 with -M)

**See also:** [docs/claude.x.md](./docs/claude.x.md)

---

### claude.init

Project initialization script that sets up Claude configuration files.

**Version:** 1.1.0
**Purpose:** Initialize or update project with Claude Code configuration

**Usage:**
```bash
claude.init [OPTIONS] [project_dir]
```

**Options:**
- `-h, --help` — Show help
- `-V, --version` — Show version
- `-v, --verbose` — Increase verbosity
- `-q, --quiet` — Suppress messages
- `-u, --claude-update` — Run `claude update` first
- `-C, --clobber` — Overwrite existing files without prompting

**What It Does:**
1. Creates/updates enterprise policy (`/etc/claude-code/CLAUDE.md`)
2. Creates project `CLAUDE.md` from template
3. Creates `BASH-CODING-STANDARD.md` symlink
4. Updates `.gitignore` with Claude-related entries

**Clobber Mode (`-C`):**

Without `--clobber`, the script prompts before modifying existing files:
- Enterprise CLAUDE.md: prompts if differs from template
- Project CLAUDE.md: prompts to append if exists
- BCS symlink: skips if exists

With `--clobber`, existing files are overwritten without prompting:
- Enterprise CLAUDE.md: overwrites
- Project CLAUDE.md: replaces (not appends)
- BCS symlink: recreates
- `.gitignore`: unchanged (append-only is correct)

**Examples:**
```bash
# Initialize current directory (interactive)
claude.init

# Initialize specific directory
claude.init /path/to/project

# Force overwrite all configs
claude.init --clobber

# Update claude first, then init with clobber
claude.init -Cu /path/to/project
```

**Permissions Set:**
- Enterprise: 664, root:claude-users
- Project files: 644

**See also:** [docs/claude.init.md](./docs/claude.init.md)

---

### claude.update

Simple wrapper for updating Claude Code CLI.

**Version:** 1.3.0
**Purpose:** Update Claude CLI to latest version

**Usage:**
```bash
./claude.update [options]
```

All arguments are passed directly to `sudo claude update`.

**Example:**
```bash
./claude.update --check
```

---

### claude.cascade

Utility script to display the CLAUDE.md memory file cascade for any directory.

**Version:** 1.2.0
**Purpose:** Visualize the hierarchical loading of CLAUDE.md files

**Usage:**
```bash
claude.cascade [directory]
```

**Output:**
```
═══════════════════════════════════════════════════════════════════
 CLAUDE.md Cascade — Load Order (lowest → highest priority)
═══════════════════════════════════════════════════════════════════

[1] Enterprise Policy
    ✓ /etc/claude-code/CLAUDE.md                    (1435 bytes)

[2] User Memory
    ✓ /home/user/.claude/CLAUDE.md                  (498 bytes)

[3] User Rules
    ▸ /home/user/.claude/rules                      (6 files)
      ✓ └─ bash-coding-standard.md                  (724 bytes)
      ✓ └─ coding-principles.md                     (169 bytes)
      ...

[4] Project Hierarchy
    ✓ /path/to/project/CLAUDE.md                    (2500 bytes)

═══════════════════════════════════════════════════════════════════
```

**Features:**
- Shows all discovered CLAUDE.md files in load order
- Displays file sizes for each memory file
- Lists contents of rules/ directories
- Indicates missing files with ✗
- Color-coded output for easy scanning

**Examples:**
```bash
# View cascade for current directory
claude.cascade

# View cascade for specific project
claude.cascade /ai/scripts/myproject

# Useful for debugging which rules are active
claude.cascade ~/work/client-project
```

---

### claude.fix-permissions

Reset permissions on Claude Code directories.

**Version:** 1.4.0
**Purpose:** Fix ownership and permissions on enterprise or user directories

**Usage:**
```bash
# Fix enterprise permissions
sudo ./claude.fix-permissions

# Fix specific user's directory
sudo ./claude.fix-permissions --user USERNAME

# Dry run
sudo ./claude.fix-permissions --dry-run
```

**Permissions Applied:**

| Scope | Directories | Files | Credentials | Ownership |
|-------|-------------|-------|-------------|-----------|
| Enterprise | 2775 (setgid) | 664 | — | root:claude-users |
| User | 755 | 644 | 600 | USER:PRIMARY_GROUP |

---

## Agent System

The agent system allows loading specialized AI personas with custom system prompts and knowledge bases.

### How Agents Work

1. **Agent Discovery** - `claude.x` checks `agents/Agents.json` (bundled) first, falls back to `locate` for system-wide version
2. **Agent Loading** - `-T AGENT` flag triggers case-insensitive lookup in Agents.json
3. **System Prompt Injection** - Agent's `systemprompt` field passed via `--append-system-prompt`
4. **Knowledge Base Loading** - Files in `knowledgebase` array are read and appended as additional system prompts
5. **Execution** - Final `exec claude` with combined configuration

### Agent Configuration Format

Agents are defined in `Agents.json` (typically located in `/Agents/`):

```json
{
  "agent-name": {
    "systemprompt": "You are a specialized agent...",
    "knowledgebase": [
      "/path/to/reference/file1.md",
      "/path/to/reference/file2.txt"
    ]
  }
}
```

### Agent Wrapper Scripts

The `agents/` directory contains specialized wrapper scripts that load pre-configured agent profiles from the dejavu2 (dv2) `Agents.json` definitions. These shims provide convenient shortcuts to commonly-used agents with additional context and customizations.

#### Available Wrappers

**get-agent-element** - Agent Configuration Utility

Extract elements from Agents.json for inspection and debugging.

```bash
# Get agent's system prompt
agents/get-agent-element leet systemprompt

# Get agent's knowledge base paths
agents/get-agent-element leet knowledgebase
```

**Usage:** `agents/get-agent-element AGENT_TAG [FIELD]`

---

**leet** - Elite Full-Stack Programmer

Elite full-stack programmer and AI systems engineer specialized in:
- Ubuntu 24.04 LTS, Bash 5.2, Python 3.12
- Web stack: Apache2, PHP 8.3, MySQL 8.0
- Frontend: HTML5, CSS3, Bootstrap 5.3, FontAwesome
- Coding principles: Efficient solutions, robust code

**Version:** 1.0.5

**Special Features:**
- Automatically adds BCS directory to context (`/ai/scripts/Okusi/bash-coding-standard`)
- Appends BCS location reference to system prompt
- Session locking via `shlock` (prevents concurrent sessions per directory)
- Configurable max output tokens (default 32K, optional 64K)
- Optional logging to `/var/log/leet.log`
- Ideal for bash script development following BCS standards

**Options:**
- `-n, --new` - Start fresh conversation
- `-c, --continue` - Resume previous conversation
- `-s, --steal` - Steal lock from another session
- `-M, --maxtokens` - Set max output tokens to 64000 (default: 32000)
- `--setup` - Setup log file (requires sudo)

```bash
# Interactive session with leet agent
agents/leet

# One-shot query
agents/leet "Optimize this bash function for performance"

# With additional options
agents/leet -vv --add-dir /data "Review my script"

# Steal lock from another session
agents/leet --steal

# Extended output tokens
agents/leet -M "Generate comprehensive documentation"

# Setup logging (one-time, requires sudo)
sudo agents/leet --setup
```

**Usage:** `agents/leet [OPTIONS] [PROMPT]`

---

**bcs-compliance** - Bash Coding Standard Expert

BCS compliance specialist that combines the leet agent with expert-level BCS knowledge for comprehensive code analysis.

**Capabilities:**
- Complete knowledge of BASH-CODING-STANDARD.summary.md
- Detailed compliance analysis and reporting
- Rule-specific violation identification
- Remediation recommendations

```bash
# Check script compliance
agents/bcs-compliance "Analyze myscript.sh for BCS compliance"

# Detailed review with verbose output
agents/bcs-compliance -v "Review all scripts in src/ directory"
```

**Usage:** `agents/bcs-compliance [OPTIONS] [PROMPT]`

**Note:** This wrapper loads the leet agent plus additional expert system prompt for BCS compliance checking.

---

**trans** - Translation Specialist

Translation agent that converts foreign language content to English while preserving markdown formatting.

**Features:**
- Auto-detects source language
- Preserves markdown structure and formatting
- Adapts cultural references for English audience
- Outputs clean translated content without commentary

```bash
# Translate a document
agents/trans "Terjemahkan dokumen ini ke bahasa Inggris"

# Translate with context preservation
agents/trans < indonesian-doc.md > english-doc.md
```

**Usage:** `agents/trans [OPTIONS] [PROMPT]`

---

**sarki** - Sarcastic Jakarta Assistant

Personality-based agent for entertainment and testing. Responds as a young Jakarta woman with sarcastic, narcissistic personality traits.

**Characteristics:**
- Responds in low-brow Jakarta Indonesian
- Unhelpful and very sarcastic
- Shallow and narcissistic persona

```bash
# Interactive session
agents/sarki

# Single query
agents/sarki "Tolong bantu saya"
```

**Usage:** `agents/sarki [OPTIONS] [PROMPT]`

---

**draa** - Applied Anthropology Expert

Applied Anthropology specialist (DrAA agent) providing insights into secular interpretations of human evolution, cultural development, and dharmic philosophy.

**Version:** 1.1.1

**Expertise:**
- Evolutionary biology and human behavioral biology
- Biological and cultural anthropology
- Human cultural and technological evolution
- Secular dharma and ethical philosophy
- Geopolitics and cultural sociology

**Features:**
- Session locking via `shlock`
- Configurable max output tokens
- Optional logging to `/var/log/draa.log`

**Options:**
- `-n, --new` - Start fresh conversation
- `-c, --continue` - Resume previous conversation
- `-s, --steal` - Steal lock from another session
- `-M, --maxtokens` - Set max output tokens to 64000 (default: 32000)
- `--setup` - Setup log file (requires sudo)

```bash
# Interactive session with DrAA agent
agents/draa

# Query about human evolution
agents/draa "Explain the role of cooperation in human evolution"

# Query about dharma concepts
agents/draa "What is secular dharma?"

# Setup logging (one-time, requires sudo)
sudo agents/draa --setup
```

**Usage:** `agents/draa [OPTIONS] [PROMPT]`

---

**Session Locking (leet, draa):** Uses `shlock` to prevent concurrent sessions per directory. Only one agent session can run at a time per directory. Use `--steal` to take over an existing session.

---

### Using Agents

```bash
# List available agents
dv2-agents list

# Load an agent
./claude.x -T leet

# View agent configuration
agents/get-agent-element leet
```

---

## SDK Examples

The `sdk/` directory contains Python examples demonstrating various use cases for the Claude Agent SDK.

### Requirements

```bash
cd sdk
pip install -r requirements.txt
# Or manually:
pip install claude-agent-sdk rich
```

### Examples

#### basic.py - Basic Query

Minimal example of querying Claude using the SDK.

```python
import asyncio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="Hello, how are you?"):
        print(message)

asyncio.run(main())
```

**Usage:**
```bash
python sdk/basic.py
```

---

#### custom-tools.py - Custom MCP Tools

Demonstrates creating custom MCP tools for Claude.

**Features:**
- Custom tool definition with `@tool` decorator
- MCP server creation with `create_sdk_mcp_server`
- Tool registration and invocation

**Example:**
```python
@tool("greet", "Greet a user", {"name": str})
async def greet(args: dict[str, Any]) -> dict[str, Any]:
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}!"
        }]
    }
```

**Usage:**
```bash
python sdk/custom-tools.py
```

**Tool Naming:** Tools are named `mcp__{server_name}__{tool_name}`

---

#### inbuild-tools.py - Built-in Tools

Shows how to use Claude's built-in tools (Read, Write) with custom options.

**Features:**
- Restricted tool access (`Read`, `Write` only)
- Permission mode configuration
- File operations through SDK

**Usage:**
```bash
python sdk/inbuild-tools.py
# Creates greeting.txt
```

---

#### agent-options.py - Agent Configuration

Demonstrates advanced agent configuration options.

**Features:**
- Custom system prompts
- Working directory configuration
- Permission mode settings

**Example:**
```python
options = ClaudeAgentOptions(
    system_prompt="You are an expert Python developer",
    permission_mode='acceptEdits',
    cwd="test"
)
```

**Usage:**
```bash
python sdk/agent-options.py
# Creates test/ directory
```

---

### SDK Test Server

Located at `sdk/test/server.py` - test server for SDK development.

**See also:** [docs/SDK.md](./docs/SDK.md) for comprehensive SDK documentation.

---

## Skills System

The `skills/` directory contains comprehensive documentation for building Claude Code skills.

### Documentation Files

- **00-README.md** - Skills system overview
- **01-Overview.md** - Conceptual introduction to skills
- **02-SKILL-Format-Specification.md** - Detailed skill format specification
- **03-Architecture-Progressive-Disclosure.md** - Progressive disclosure architecture
- **04-Installation-Setup.md** - Installation and setup guide
- **05-API-Integration.md** - API integration documentation
- **06-Best-Practices.md** - Best practices for skill development
- **07-Security-Permissions.md** - Security and permissions guide
- **08-Example-Skills-Catalog.md** - Catalog of example skills
- **09-Skills-vs-MCP.md** - Skills vs MCP comparison
- **10-Limitations-Constraints.md** - Known limitations and constraints
- **11-Quick-Reference.md** - Quick reference guide

### Skills Repository

**Note:** The `skills/repos/` directory contains skill examples but is excluded from version control via `.gitignore`. See individual skill documentation for details.

---

## Project Structure

```
/ai/scripts/claude/
├── README.md                          # This file
├── LICENSE                            # License file
│
├── claude.x                           # Main wrapper script (v1.2.0)
├── claude.init                        # Project initialization (v1.1.0)
├── claude.update                      # Update wrapper (v1.3.0)
├── claude.cascade                     # CLAUDE.md hierarchy viewer (v1.2.0)
├── claude.fix-permissions             # Permission fixer (v1.4.0)
├── claude-install.md                  # Installation guide
│
├── CLAUDE.canonical.md                # Canonical config template
├── .bash_completion                   # Bash completion support
│
├── agents/                            # Agent utilities
│   ├── Agents.json                    # Agent definitions (synced from dejavu2-cli)
│   ├── sync-agents-json               # Sync utility for Agents.json
│   ├── get-agent-element              # Agent config extractor
│   ├── bcs-compliance                 # BCS compliance agent
│   ├── draa                           # Applied Anthropology agent
│   ├── leet                           # Leet agent
│   ├── sarki                          # Sarki agent
│   └── trans                          # Translation agent
│
├── sdk/                               # SDK examples
│   ├── requirements.txt               # Python dependencies
│   ├── basic.py                       # Basic usage example
│   ├── custom-tools.py                # Custom tool creation
│   ├── inbuild-tools.py               # Built-in tools usage
│   ├── agent-options.py               # Agent configuration
│   ├── greeting.txt                   # Example output file
│   └── test/
│       └── server.py                  # Test server
│
├── skills/                            # Skills documentation
│   ├── 00-README.md                   # Skills overview
│   ├── 01-Overview.md                 # Conceptual introduction
│   ├── 02-SKILL-Format-Specification.md
│   ├── 03-Architecture-Progressive-Disclosure.md
│   ├── 04-Installation-Setup.md
│   ├── 05-API-Integration.md
│   ├── 06-Best-Practices.md
│   ├── 07-Security-Permissions.md
│   ├── 08-Example-Skills-Catalog.md
│   ├── 09-Skills-vs-MCP.md
│   ├── 10-Limitations-Constraints.md
│   └── 11-Quick-Reference.md
│
└── docs/                              # Additional documentation
    ├── claude.x.md                    # claude.x details
    ├── claude.init.md                 # claude.init details
    └── SDK.md                         # SDK comprehensive guide
```

## Requirements

### System Requirements

- **OS:** Ubuntu 24.04.3 (or compatible Linux)
- **Shell:** Bash 5.2+
- **Python:** 3.12+ (for SDK examples)
- **Node.js:** v22.x LTS or higher
- **Memory:** Minimum 4GB RAM recommended

### Command-line Dependencies

**Required:**
- `jq` - JSON processing (required for agent system)
- `locate` - File location (required for agent discovery)
- `curl` - HTTP client (for installation)
- `realpath` - Path resolution

**Optional:**
- `remblanks` - .gitignore cleanup in claude.init
- `shellcheck` - Shell script linting
- `shlock` - Session locking for agent wrappers (leet, draa)

### Python Dependencies (for SDK)

```bash
pip install claude-agent-sdk rich
```

Or use the requirements file:
```bash
cd sdk
pip install -r requirements.txt
```

### Installation Verification

```bash
# Check versions
bash --version    # Should be 5.2+
python --version  # Should be 3.12+
node -v          # Should be v22+
jq --version     # Should be present
claude --version # Should show installed version

# Verify claude.x works
./claude.x --help
```

## Configuration

### Environment Setup

Add to your `~/.bashrc` or `~/.bash_profile`:

```bash
# Claude utilities
export PATH="/ai/scripts/claude:$PATH"

# Optional: Bash completion
source /ai/scripts/claude/.bash_completion
```

### Agent Configuration

Ensure your `Agents.json` is in a searchable location (typically `/Agents/Agents.json`).

Update locate database if needed:
```bash
sudo updatedb
```

### Project-Specific Configuration

Create a `CLAUDE.md` in your project root with project-specific instructions:

```bash
cd /path/to/project
/ai/scripts/claude/claude.init
```

This creates:
- `CLAUDE.md` - Project instructions for Claude
- `.gudang/` - Project data directory
- `BASH-CODING-STANDARD.md` - BCS reference symlink

## Bash Coding Standard (BCS)

This toolkit integrates with the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard).

### BCS Reference

- `BASH-CODING-STANDARD.md` - Symlink to `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md`

### BCS Integration

All bash scripts in this repository follow BCS requirements:

- Shebang: `#!/bin/bash`
- Error handling: `set -euo pipefail`
- Shell options: `shopt -s inherit_errexit extglob nullglob`
- Script metadata: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- End marker: `#fin`

### Using BCS Agent

```bash
# Load BCS compliance agent
./claude.x -T leet --add-dir /ai/scripts/Okusi/bash-coding-standard

# Or use specialized wrapper
agents/bcs-compliance
```

---

## Development

### Agents.json Synchronization

The repository includes a copy of `Agents.json` from the [dejavu2-cli](https://github.com/Open-Technology-Foundation/dejavu2-cli) project. This file contains agent definitions (system prompts and knowledge bases) used by the agent wrapper scripts.

**For developers with dejavu2-cli installed:**

The `Agents.json` file is automatically synced when using `.gitcommit`:

```bash
# Automatic sync during commit
./.gitcommit "your commit message"
```

This runs `agents/sync-agents-json` before staging files, ensuring the latest agent definitions are included in commits.

**Manual sync:**

```bash
# Sync from dejavu2-cli
agents/sync-agents-json
```

**For end users:**

No action needed - `Agents.json` is included in the repository and tracked in version control. The agent wrappers will work out of the box.

**How it works:**

1. `claude.x` checks for `agents/Agents.json` first (bundled version)
2. If not found, falls back to `locate` to find system-wide Agents.json
3. Developers with dejavu2-cli get automatic sync via `.gitcommit`
4. End users cloning from GitHub use the bundled version

**Source:** `/ai/scripts/dejavu2-cli/Agents/Agents.json`

---

## Enterprise Standards

The Okusi Group enterprise configuration enforces organization-wide standards.

### Git Authorship

All commits must follow these rules:
- Author: **Biksu Okusi**
- Never mention "claude" or "claude code" in commit messages
- Use conventional commit style when appropriate

```bash
# Correct
git commit -m "feat: add user authentication module"

# Incorrect
git commit -m "Claude helped me add authentication"
```

### Documentation Icons

Use these standardized icons in documentation:

| Purpose | Icon | Usage |
|---------|------|-------|
| Info | ◉ | General information |
| Debug | ⦿ | Debug output, technical details |
| Warning | ▲ | Important warnings, cautions |
| Success | ✓ | Successful operations, checkmarks |
| Error | ✗ | Errors, failures, missing items |

### Coding Principles

- **K.I.S.S.** — Keep It Simple, Stupid
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler"

### Environment Requirements

| Component | Version |
|-----------|---------|
| **OS** | Ubuntu 24.04+ |
| **Bash** | 5.2+ |
| **Python** | 3.12+ |
| **Node.js** | 22.x LTS |

### Multi-Server Navigation (oknav)

Use oknav shortcuts for remote server access:

```bash
ok0 uptime               # Run command on ok0
ok1 -r systemctl status  # Connect as root
ok1 -d                   # Preserve current working directory
oknav uptime             # Sequential on all servers
oknav -p 'df -h'         # Parallel execution
```

| Alias | Server | Notes |
|-------|--------|-------|
| `ok0` | okusi0 | Primary |
| `ok1` | okusi1 | — |
| `ok2` | okusi2 | — |
| `ok3` | okusi3 | — |
| `okdev` | okusi | Dev (local-only) |

▲ **Important**: Never use `ok_master` directly — always use hostname symlinks.

---

## Troubleshooting

### Common Issues

**Issue:** `Agents.json not found`
**Solution:**
- The bundled version should be at `agents/Agents.json`
- For developers: Sync from dejavu2-cli: `agents/sync-agents-json`
- Alternative: Update locate database to find system-wide version:
```bash
sudo updatedb
locate -b '\Agents.json'
```

---

**Issue:** Permission denied on scripts
**Solution:**
```bash
chmod +x claude.x claude.init claude.update
```

---

**Issue:** `claude: command not found`
**Solution:** Verify Claude Code installation and PATH configuration:
```bash
echo $PATH
which claude
npm list -g @anthropic-ai/claude-code
```

---

**Issue:** SDK examples fail
**Solution:** Install required Python packages:
```bash
cd sdk
pip install claude-agent-sdk rich
```

---

**Issue:** `remblanks: command not found` during claude.init
**Solution:** This is optional. The script will continue without it. To fix:
- Install remblanks utility, or
- Manually clean .gitignore after initialization

---

**Issue:** Agent not loading
**Solution:** Check agent exists and verify configuration:
```bash
agents/get-agent-element your-agent-name
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Single verbose
./claude.x -v -T leet

# Double verbose (shows full command)
./claude.x -vv -T leet

# Triple verbose
./claude.x -vvv -T leet
```

## References

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)

## Support

For issues and questions:
- Check existing documentation in `docs/`
- Review skills documentation in `skills/`
- Consult [claude-install.md](./claude-install.md) for installation issues

## License

See [LICENSE](./LICENSE) file in the repository root.

---

**Version:** 2.6.0
**Last Updated:** 2026-01-11

#fin
