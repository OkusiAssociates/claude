# Claude Code Utilities - Purpose, Functionality, and Usage

**Analysis Date:** 2025-12-24
**Repository:** `/ai/scripts/claude/`
**Version:** 2.0.0

---

## ◉ Purpose

### What Problem Does This Project Solve?

This repository provides a **comprehensive power-user toolkit** for Claude Code CLI that addresses several key challenges:

1. **Streamlined Dangerous Mode Operation**: The native Claude CLI requires multiple confirmations for file operations. This toolkit pre-configures "dangerous" permissions for unrestricted file operations, ideal for development workflows where you trust Claude's actions.

2. **AI Agent Personas**: Enables loading specialized AI agents with custom system prompts and domain knowledge bases, transforming Claude from a generic assistant into task-specific experts (coding, translation, compliance checking).

3. **Project Initialization Automation**: Standardizes the setup of new projects with canonical configurations, ensuring consistent CLAUDE.md files, BCS (Bash Coding Standard) references, and proper .gitignore entries.

4. **SDK Integration Examples**: Provides working Python examples for programmatic Claude access via the Claude Agent SDK.

5. **Skills Documentation Hub**: Comprehensive research documentation on Claude Skills (Anthropic's October 2025 feature) for developers building custom capabilities.

### Who Is It For?

- **Power users** of Claude Code CLI who want faster, less-interrupted workflows
- **Developers** working on bash scripts who need BCS compliance guidance
- **Teams** wanting consistent Claude configurations across projects
- **SDK developers** building programmatic Claude integrations
- **Skill creators** researching Claude's new Skills system

---

## ◉ Functionality

### Core Components

| Component | Purpose | Version |
|-----------|---------|---------|
| `claude.x` | Main wrapper with dangerous permissions + agent loading | 1.0.8 |
| `claude.init` | Project initialization with canonical CLAUDE.md setup | 1.0.3 |
| `claude.update` | Simple `sudo claude update` wrapper | 1.0.0 |
| `agents/` | Specialized agent wrapper scripts | - |
| `sdk/` | Python SDK examples | - |
| `skills/` | Claude Skills documentation (12 files, 6,763 lines) | 1.0 |

### Key Features

#### 1. Agent Template System (`claude.x -T AGENT`)

The heart of this toolkit is the agent loading system:

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│   claude.x  │────>│  Agents.json    │────>│  claude CLI  │
│  -T <agent> │     │  (61K+ JSON)    │     │  with agent  │
└─────────────┘     └─────────────────┘     │  prompts     │
                                            └──────────────┘
```

**Available Agents** (defined in `agents/Agents.json`):
- **leet** - Elite full-stack programmer (Bash, Python, PHP, JavaScript)
- **trans** - Translation specialist (any language → English)
- **bcs-compliance** - Bash Coding Standard expert
- **sarki** - Sarcastic Jakarta assistant (testing/entertainment)
- **askOkusi** - Indonesian PMA/FDI business advisor
- **DrAA** - Applied Anthropology specialist
- And 40+ more specialized agents

#### 2. Dangerous Permissions Mode

Pre-configured options automatically passed to Claude:
```bash
--allowedTools Read Write Edit Bash
--permission-mode acceptEdits
--dangerously-skip-permissions  # (when not root)
```

**Default additional directories:**
- `$HOME`, `/tmp`, `/ai`, `/usr/local/`, `/usr/share`

#### 3. Automatic Conversation Continuation

The wrapper intelligently handles conversation state:
- Auto-detects existing conversations for current directory
- Continues if found, starts fresh otherwise
- Override with `--new` or explicit `--continue`

#### 4. BCS Integration

Seamless integration with the Bash Coding Standard:
- Symlinks to `/ai/scripts/Okusi/bash-coding-standard/`
- Agent wrappers append BCS location to system prompts
- Specialized `bcs-compliance` agent for code auditing

#### 5. SDK Examples

Four Python examples demonstrating Claude Agent SDK usage:

| File | Demonstrates |
|------|--------------|
| `basic.py` | Minimal async query |
| `custom-tools.py` | Creating MCP tools with `@tool` decorator |
| `inbuild-tools.py` | Using built-in Read/Write tools |
| `agent-options.py` | Advanced agent configuration |

#### 6. Skills Documentation

Comprehensive research documentation (12 files) covering:
- SKILL.md format specification
- Progressive disclosure architecture (3-tier token efficiency)
- Installation and setup
- Best practices and security
- Skills vs MCP comparison

---

## ◉ Usage

### Quick Start

#### Basic Usage (Interactive Session)
```bash
# Start Claude with dangerous permissions
./claude.x

# With verbose output
./claude.x -v
./claude.x -vv  # Shows full command array
```

#### Using Agent Templates
```bash
# Load specific agent
./claude.x -T leet      # Elite programmer
./claude.x -T trans     # Translator
./claude.x -T DrAA      # Applied Anthropologist

# Or use agent wrapper scripts (recommended)
agents/leet             # Leet with BCS context
agents/bcs-compliance   # BCS compliance expert
agents/trans            # Translator
```

#### One-Shot Queries
```bash
# Any non-option argument triggers --print mode
./claude.x "Explain the main() function"
./claude.x -T trans "Terjemahkan dokumen ini"
```

#### Project Initialization
```bash
cd /path/to/new-project
/ai/scripts/claude/claude.init

# Creates:
#   - CLAUDE.md (from canonical template)
#   - .gudang/ (project data directory)
#   - BASH-CODING-STANDARD.md (symlink)
#   - Updates .gitignore
#   - Runs sudo claude update
#   - Launches claude.x -T leet
```

### Common Workflows

#### 1. Development Session with Leet Agent
```bash
cd /path/to/project
agents/leet

# Or manually:
./claude.x -T leet --add-dir /data/custom-context
```

#### 2. BCS Compliance Check
```bash
agents/bcs-compliance "Analyze myscript.sh for BCS compliance"

# Or for detailed review:
agents/bcs-compliance -v "Review all scripts in src/"
```

#### 3. Translation Task
```bash
agents/trans "Translate this Indonesian document to English"

# Or piped:
cat indonesian-doc.md | agents/trans > english-doc.md
```

#### 4. Inspect Agent Configuration
```bash
# View agent's system prompt
agents/get-agent-element leet systemprompt

# View knowledge base paths
agents/get-agent-element leet knowledgebase
```

#### 5. SDK Development
```bash
cd sdk/

# Install dependencies
pip install -r requirements.txt
# Or: pip install claude-agent-sdk rich

# Run examples
python basic.py           # Basic query
python custom-tools.py    # Custom MCP tools
python inbuild-tools.py   # Built-in tools (creates greeting.txt)
python agent-options.py   # Agent config (creates test/)
```

### Command Reference

#### claude.x Options
```
-T AGENT              Load agent template (case-insensitive)
-n, --new             Start fresh conversation
--no-continue         Alias for --new
-c, --continue        Resume previous conversation
-v, --verbose         Increase verbosity (-vv, -vvv)
-q, --quiet           Suppress informational messages
-h, --help            Show help message
-V, --version         Show version
--add-dir PATH        Add directory to context
--append-system-prompt TEXT  Add custom system prompt
```

#### claude.init Options
```
-h, --help            Show help
--version             Show version
```

#### agents/leet Options
```
-n, --new             Start fresh conversation
-c, --continue        Resume conversation
-s, --steal           Steal lock from another session
-M, --maxtokens       Set max output tokens to 64000
--setup               Setup log file (requires sudo)
```

---

## ◉ Architecture

### Execution Flow

```
┌────────────────┐
│  claude.init   │  (Project setup)
│    or          │
│  agents/leet   │  (Agent wrapper)
│    or          │
│  ./claude.x    │  (Direct invocation)
└───────┬────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────┐
│                       claude.x                             │
│                                                            │
│  1. Parse arguments (-T, -n, -v, etc.)                    │
│  2. Locate Agents.json (bundled or system-wide)           │
│  3. Load agent systemprompt + knowledgebase files         │
│  4. Build claude command array:                           │
│     - --allowedTools Read Write Edit Bash                 │
│     - --permission-mode acceptEdits                       │
│     - --dangerously-skip-permissions                      │
│     - --append-system-prompt (agent content)              │
│     - --add-dir (default + custom directories)            │
│     - --continue (if conversation exists)                 │
│  5. exec claude "${claude_cmd[@]}"                        │
│                                                            │
└───────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────┐
│                  claude CLI                               │
│  (Anthropic's official Claude Code CLI)                   │
└───────────────────────────────────────────────────────────┘
```

### Directory Structure
```
/ai/scripts/claude/
├── claude.x                    # Main wrapper (329 lines)
├── claude.init                 # Project init (57 lines)
├── claude.update               # Update wrapper (simple)
├── CLAUDE.canonical.md         # Template for new projects
│
├── agents/
│   ├── Agents.json             # Agent definitions (61K+)
│   ├── leet                    # Leet agent wrapper
│   ├── bcs-compliance          # BCS expert wrapper
│   ├── trans                   # Translator wrapper
│   ├── sarki                   # Sarcastic assistant
│   ├── get-agent-element       # Config extractor
│   └── sync-agents-json        # Sync from dejavu2-cli
│
├── sdk/
│   ├── basic.py                # Minimal SDK example
│   ├── custom-tools.py         # MCP tool creation
│   ├── inbuild-tools.py        # Built-in tools
│   └── agent-options.py        # Agent configuration
│
├── skills/                     # Skills documentation
│   ├── 00-README.md            # Master index
│   ├── 01-Overview.md          # Introduction
│   ├── 02-SKILL-Format-Specification.md
│   ├── 03-Architecture-Progressive-Disclosure.md
│   └── ... (12 total files)
│
└── docs/
    ├── claude.x.md             # Detailed claude.x docs
    ├── claude.init.md          # Initialization guide
    └── SDK.md                  # SDK comprehensive guide
```

---

## ◉ Requirements

### System Requirements
- **OS**: Ubuntu 24.04+ (or compatible Linux)
- **Shell**: Bash 5.2+
- **Node.js**: v22.x LTS (for Claude Code CLI)
- **Python**: 3.12+ (for SDK examples)

### Command Dependencies
| Command | Required | Purpose |
|---------|----------|---------|
| `claude` | Yes | Claude Code CLI |
| `jq` | Yes | JSON processing for agent system |
| `locate` | Yes (fallback) | Agent file discovery |
| `realpath` | Yes | Path resolution (BCS) |
| `remblanks` | Optional | .gitignore cleanup |
| `shlock` | Optional | Session locking (leet wrapper) |

### Python Dependencies (SDK)
```bash
pip install claude-agent-sdk rich
```

---

## ◉ Integration Points

### BCS (Bash Coding Standard)
- Location: `/ai/scripts/Okusi/bash-coding-standard/`
- Primary file: `BASH-CODING-STANDARD.md`
- Summary: `data/BASH-CODING-STANDARD.summary.md`
- All scripts in this repo follow BCS

### dejavu2-cli (Agent Source)
- Agents.json synced from `/ai/scripts/dejavu2-cli/Agents/Agents.json`
- Use `agents/sync-agents-json` for manual sync
- Automatic sync via `.gitcommit` for developers

### Claude Skills (Future)
- Skills documentation in `skills/`
- Currently SKILL.md files not auto-loading in CLI (per testing Oct 2025)
- Use CLAUDE.md as current workaround

---

## ◉ Important Notes

### Security Considerations
▲ **WARNING**: The `--dangerously-skip-permissions` flag allows unrestricted file operations. Only use in trusted environments.

### Conversation Persistence
- Conversations stored in `/usr/share/claude/.claude/projects/`
- Directory name derived from PWD (slashes replaced with dashes)
- Use `--new` to force fresh start

### Agent Discovery Priority
1. Bundled: `$SCRIPT_DIR/agents/Agents.json`
2. Fallback: `locate -b '\Agents.json'` (excluding checkpoints)

### Verbose Debugging
```bash
# Level 1: Basic info messages
./claude.x -v -T leet

# Level 2: Full command array dump
./claude.x -vv -T leet

# Level 3: Maximum verbosity
./claude.x -vvv -T leet
```

---

## ◉ References

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)
- [Claude Skills Announcement](https://www.anthropic.com/news/skills)

---

**Maintained by:** Gary Dean (Biksu Okusi), Okusi Group
**License:** See LICENSE file

#fin
