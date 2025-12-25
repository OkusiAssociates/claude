# Claude Code Utilities

A comprehensive toolkit for extending and customizing Claude Code CLI with advanced features including agent templates, project initialization, and SDK examples.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Scripts](#core-scripts)
  - [claude.x](#claudex)
  - [claude.init](#claudeinit)
  - [claude.update](#claudeupdate)
- [Agent System](#agent-system)
- [SDK Examples](#sdk-examples)
- [Skills System](#skills-system)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Configuration](#configuration)
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

## Installation

### Prerequisites

- **Node.js LTS** (v22.x or higher)
- **npm** configured for global packages
- **Claude Code CLI** installed
- **Python 3.12+** (for SDK examples)

### Quick Install

```bash
# 1. Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Configure npm for global packages (no sudo required)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 3. Install Claude Code
npm install -g @anthropic-ai/claude-code
claude --version

# 4. Clone/access this repository
cd /ai/scripts/claude
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

**Version:** 1.0.8
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
- Smart conversation continuation (auto-detects existing conversations)

**Options:**
- `-T AGENT` - Load agent template (e.g., leet, trans, sarki, draa)
- `-n, --new, --no-continue` - Start fresh conversation
- `-c, --continue` - Force continue previous conversation
- `-v, --verbose` - Increase verbosity (repeatable: -vv, -vvv)
- `-q, --quiet` - Suppress informational messages
- `-h, --help` - Show help message
- `-V, --version` - Show version information

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

**See also:** [docs/claude.x.md](./docs/claude.x.md)

---

### claude.init

Project initialization script that sets up Claude configuration files.

**Version:** 1.0.3
**Purpose:** Create canonical CLAUDE.md and initialize project structure

**Usage:**
```bash
cd /path/to/project
/ai/scripts/claude/claude.init
```

**What It Does:**
1. Updates Claude to latest version (`sudo claude update`)
2. Creates `.gudang` directory for project data
3. Creates BASH-CODING-STANDARD.md symlink to `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md`
4. Initializes or appends to CLAUDE.md with canonical configuration
5. Updates .gitignore with appropriate entries
6. Launches `claude.x -T leet`

**Interactive Prompts:**
- Confirms appending to existing CLAUDE.md
- Confirms initialization in new directories

**Files Created/Modified:**
- `CLAUDE.md` - Project-specific instructions for Claude
- `.gudang/` - Project data directory
- `BASH-CODING-STANDARD.md` - Symlink to BCS documentation
- `.gitignore` - Updated with CLAUDE.md, .gudang, BASH-CODING-STANDARD.md

**See also:** [docs/claude.init.md](./docs/claude.init.md)

---

### claude.update

Simple wrapper for updating Claude Code CLI.

**Version:** 1.0.0
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

**Version:** 1.0.4

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
- `-M, --maxtokens` - Set max output tokens to 64000
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

**Version:** 1.0.0

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
- `-M, --maxtokens` - Set max output tokens to 64000
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
├── claude.x                           # Main wrapper script (v1.0.8)
├── claude.init                        # Project initialization (v1.0.3)
├── claude.update                      # Update wrapper (v1.0.0)
├── claude-install.md                  # Installation guide
│
├── CLAUDE.canonical.md                # Canonical config template
├── CLAUDE.user.md                     # Symlink to ~/.claude/CLAUDE.md
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
- Shell options: `shopt -s inherit_errexit shift_verbose extglob nullglob`
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

**Version:** 2.1.0
**Last Updated:** 2025-12-24

#fin
