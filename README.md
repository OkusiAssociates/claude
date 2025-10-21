# Claude Code Utilities

A comprehensive toolkit for extending and customizing Claude Code CLI with advanced features including agent templates, BCS compliance checking, and SDK examples.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Scripts Reference](#scripts-reference)
- [SDK Examples](#sdk-examples)
- [Agent System](#agent-system)
- [BCS Compliance](#bcs-compliance)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Contributing](#contributing)

## Overview

This repository provides a suite of wrapper scripts and utilities for Claude Code CLI that enable:
- Running Claude with custom agent templates and system prompts
- Bash Coding Standard (BCS) compliance checking
- Project initialization and configuration management
- SDK integration examples for programmatic access

## Features

◉ **Agent Template System** - Load specialized AI agents with custom system prompts and knowledge bases
◉ **Dangerous Mode Wrapper** - Pre-configured permissions for unrestricted file operations
◉ **BCS Integration** - Built-in Bash Coding Standard compliance checking
◉ **SDK Examples** - Python examples demonstrating Claude Agent SDK usage
◉ **Auto-initialization** - Streamlined project setup with canonical configurations

## Installation

### Prerequisites

- Node.js LTS (v22.x or higher)
- npm configured for global packages
- Claude Code CLI installed

### Quick Install

For detailed installation instructions, see [claude-install.md](./claude-install.md).

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

### With Agent Templates

```bash
# Use the BCS compliance agent
./claude.x.bcs-compliance

# Use the leet agent with additional directories
./claude.x -T leet --add-dir /path/to/additional/context
```

## Scripts Reference

### claude.x

Main wrapper script for Claude Code with enhanced permissions and agent support.

**Location:** `/ai/scripts/claude/claude.x`
**Version:** 1.0.4
**Purpose:** Run Claude with 'dangerous' settings and optional Agent system prompts

**Usage:**
```bash
claude.x [-h|--help] [-T agent] [--claude_opts...] [prompt]
```

**Key Features:**
- Pre-configured with `--allowedTools Read Write Edit Bash`
- Permission mode: `acceptEdits`
- Dangerously skip permissions (auto-accept all operations)
- Agent template loading from Agents.json
- Multiple working directories support

**Options:**
- `-n, --new, --no-continue` - Start fresh conversation
- `-T AGENT` - Load agent template (e.g., leet, trans, mydharma)
- `-v, --verbose` - Increase verbosity
- `-q, --quiet` - Suppress informational messages
- `-h, --help` - Show help message

**Examples:**
```bash
# Basic usage
claude.x

# Load specific agent
claude.x -T leet

# Add additional context directories
claude.x -T mydharma --add-dir /data

# One-shot query with agent
claude.x -T trans "Translate this code to Python"
```

**Default Directories:**
The script automatically adds these directories to Claude's context:
- `$HOME`
- `/tmp`
- `/ai`
- `/usr/local/`
- `/usr/share`

**See:** [claude.x documentation](./docs/claude.x.md) for detailed information

---

### claude.init

Project initialization script that sets up Claude configuration files.

**Location:** `/ai/scripts/claude/claude.init`
**Version:** 1.0.3
**Purpose:** Create canonical CLAUDE.md and initialize project structure

**Usage:**
```bash
cd /path/to/project
/ai/scripts/claude/claude.init
```

**What It Does:**
1. Updates Claude to latest version
2. Creates `.gudang` directory for project data
3. Creates BASH-CODING-STANDARD.md symlink
4. Initializes or appends to CLAUDE.md with canonical configuration
5. Updates .gitignore appropriately
6. Launches claude.x

**Interactive Prompts:**
- Confirms appending to existing CLAUDE.md
- Confirms initialization in new directories

**See:** [claude.init documentation](./docs/claude.init.md)

---

### claude.update

Simple wrapper for updating Claude Code CLI.

**Location:** `/ai/scripts/claude/claude.update`
**Version:** 1.0.0
**Purpose:** Update Claude CLI to latest version

**Usage:**
```bash
./claude.update [options]
```

All arguments are passed directly to `claude update`.

---

### claude.x.bcs-compliance

Specialized wrapper for Bash Coding Standard compliance checking.

**Location:** `/ai/scripts/claude/claude.x.bcs-compliance`
**Version:** 1.0.1
**Purpose:** Launch Claude with BCS compliance expert agent

**Usage:**
```bash
./claude.x.bcs-compliance [options] [prompt]
```

**Features:**
- Pre-loads leet agent
- Adds BCS directory to context
- Includes BCS expert system prompt
- References `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.summary.md`

**Example:**
```bash
./claude.x.bcs-compliance "Review this script for BCS compliance"
```

**See:** [BCS Compliance Reports](./BCS-COMPLIANCE-REPORT.md) for analysis results

---

### claude.x.leet

Lightweight wrapper for the leet agent with BCS awareness.

**Location:** `/ai/scripts/claude/claude.x.leet`
**Version:** 1.0.1
**Purpose:** Launch Claude with leet agent and BCS context

**Usage:**
```bash
./claude.x.leet [options] [prompt]
```

---

### agents/get-agent-element

Utility script to extract agent configuration from Agents.json.

**Location:** `/ai/scripts/claude/agents/get-agent-element`
**Purpose:** Extract agent elements (systemprompt, knowledgebase) from Agents.json

**Usage:**
```bash
get-agent-element AgentTag [fieldname]
```

**Parameters:**
- `AgentTag` - Name of agent in Agents.json
- `fieldname` - Optional field to extract (systemprompt, knowledgebase)

**Example:**
```bash
# Get entire agent configuration
get-agent-element leet

# Get only the system prompt
get-agent-element leet systemprompt
```

## SDK Examples

The `sdk/` directory contains Python examples demonstrating various use cases for the Claude Agent SDK.

### basic.py

Minimal example of querying Claude using the SDK.

**Location:** `/ai/scripts/claude/sdk/basic.py`

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
cd sdk
python basic.py
```

**See:** [SDK Documentation](./docs/SDK.md#basic-usage)

---

### custom-tools.py

Demonstrates creating custom MCP tools for Claude.

**Location:** `/ai/scripts/claude/sdk/custom-tools.py`

**Features:**
- Custom tool definition with `@tool` decorator
- MCP server creation
- Tool registration and invocation

**Example Custom Tool:**
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
cd sdk
python custom-tools.py
```

**See:** [SDK Documentation](./docs/SDK.md#custom-tools)

---

### inbuild-tools.py

Shows how to use Claude's built-in tools (Read, Write) with custom options.

**Location:** `/ai/scripts/claude/sdk/inbuild-tools.py`

**Features:**
- Restricted tool access (`Read`, `Write` only)
- Permission mode configuration
- File operations through SDK

**Usage:**
```bash
cd sdk
python inbuild-tools.py
```

**See:** [SDK Documentation](./docs/SDK.md#built-in-tools)

---

### agent-options.py

Demonstrates advanced agent configuration options.

**Location:** `/ai/scripts/claude/sdk/agent-options.py`

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
cd sdk
python agent-options.py
```

**See:** [SDK Documentation](./docs/SDK.md#agent-options)

## Agent System

The agent system allows loading specialized AI personas with custom system prompts and knowledge bases.

### Agent Configuration

Agents are defined in `Agents.json` (typically located via `locate -b '\Agents.json'`).

**Structure:**
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

### Using Agents

```bash
# List available agents
dv2-agents list

# Load an agent
claude.x -T agent-name

# View agent configuration
agents/get-agent-element agent-name
```

### Available Agents

The available agents depend on your `Agents.json` configuration. Common agents include:
- `leet` - Elite coding standards expert
- `trans` - Translation specialist
- `mydharma` - Custom project assistant

Use `dv2-agents list` to see all available agents in your system.

## BCS Compliance

### Bash Coding Standard Integration

This toolkit includes built-in support for the [Bash Coding Standard (BCS)](https://github.com/Open-Technology-Foundation/bash-coding-standard).

**Key Files:**
- `BASH-CODING-STANDARD.md` - Symlink to BCS documentation
- `BCS-COMPLIANCE-REPORT.md` - Latest compliance analysis
- `BCS-FIXES-APPLIED.md` - Record of applied fixes

### Running BCS Compliance Checks

```bash
# Interactive compliance checking
./claude.x.bcs-compliance

# With specific script
./claude.x.bcs-compliance "Check script.sh for BCS compliance"
```

### Compliance Reports

See [BCS-COMPLIANCE-REPORT.md](./BCS-COMPLIANCE-REPORT.md) for detailed analysis of scripts in this repository.

**Current Repository Compliance:** 60%

▲ **Priority Issues:**
- Missing `shopt` settings in all scripts
- Missing metadata in some utility scripts
- Syntax errors in `agents/get-agent-element`

## Project Structure

```
/ai/scripts/claude/
├── README.md                          # This file
├── claude.x                           # Main wrapper script
├── claude.init                        # Project initialization
├── claude.update                      # Update wrapper
├── claude.x.bcs-compliance            # BCS compliance checker
├── claude.x.leet                      # Leet agent wrapper
├── .bash_completion                   # Bash completion support
├── BASH-CODING-STANDARD.md            # Symlink to BCS docs
├── BCS-COMPLIANCE-REPORT.md           # BCS analysis report
├── BCS-FIXES-APPLIED.md               # Applied fixes log
├── CLAUDE.canonical.md                # Canonical config template
├── claude-install.md                  # Installation guide
├── prompt-structure.md                # Prompt engineering guide
├── .claude/                           # Claude configuration
├── agents/                            # Agent utilities
│   └── get-agent-element              # Agent config extractor
├── sdk/                               # SDK examples
│   ├── basic.py                       # Basic usage
│   ├── custom-tools.py                # Custom tool creation
│   ├── inbuild-tools.py               # Built-in tools usage
│   └── agent-options.py               # Agent configuration
└── docs/                              # Documentation (generated)
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

### Dependencies

**Command-line Tools:**
- `jq` - JSON processing (required for agent system)
- `locate` - File location (required for agent discovery)
- `curl` - HTTP client (for installation)
- `realpath` - Path resolution

**Python Packages (for SDK examples):**
```bash
pip install claude-agent-sdk rich
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

# Optional: Default agent
export CLAUDE_DEFAULT_AGENT="leet"
```

### Bash Completion

Bash completion is available in `.bash_completion`. Source it in your shell:

```bash
source /ai/scripts/claude/.bash_completion
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
- `BASH-CODING-STANDARD.md` - BCS reference

## Contributing

### Development Standards

All bash scripts in this repository follow the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard).

**Key Requirements:**
- Shebang: `#!/bin/bash`
- Error handling: `set -euo pipefail`
- Shell options: `shopt -s inherit_errexit shift_verbose extglob nullglob`
- Script metadata: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- End marker: `#fin`

### Testing Changes

```bash
# Run shellcheck
shellcheck script.sh

# Check BCS compliance
./claude.x.bcs-compliance "Check script.sh"

# Test with verbose mode
./claude.x -v -T leet "test query"
```

### Submitting Changes

1. Ensure scripts pass shellcheck
2. Verify BCS compliance
3. Update documentation
4. Test all affected functionality

## Troubleshooting

### Common Issues

**Issue:** `Agents.json not found`
**Solution:** Ensure Agents.json is in a searchable location or set the path explicitly

**Issue:** Permission denied on scripts
**Solution:**
```bash
chmod +x claude.x claude.init claude.update
```

**Issue:** `claude: command not found`
**Solution:** Verify Claude Code installation and PATH configuration

**Issue:** SDK examples fail
**Solution:** Install required Python packages:
```bash
pip install claude-agent-sdk rich
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
./claude.x -v -v -T leet "your query"
```

## License

See the LICENSE file in the repository root.

## References

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)

## Support

For issues and questions:
- Check existing documentation in `docs/`
- Review [BCS-COMPLIANCE-REPORT.md](./BCS-COMPLIANCE-REPORT.md)
- Consult [prompt-structure.md](./prompt-structure.md) for prompt engineering guidance

---

**Version:** 1.0.0
**Last Updated:** 2025-10-19

#fin
