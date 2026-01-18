# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a toolkit of wrapper scripts and utilities for Claude Code CLI that provide:
- **claude.x** (v1.2.0) - Main wrapper with 'dangerous' permissions and agent template loading
- **claude.init** (v1.1.0) - Project initialization with CLAUDE.md setup
- **claude.update** (v1.3.0) - Claude CLI update wrapper
- **Agent wrappers** - Symlink-based wrappers in `agents/` (leet, draa, trans, sarki)
- **Enterprise deployment** - Enterprise deployment scripts in `enterprise/`
- **SDK examples** - Python examples demonstrating Claude Agent SDK usage
- **Skills documentation** - Comprehensive guides in `skills/` (11 documentation files)

## Architecture

### Script Hierarchy

```
claude.init                  # Entry point for new projects
    └─> claude.x -T leet     # Main wrapper (exec'd at end)
            └─> claude       # Actual Claude CLI (exec'd)

agents/bcs-compliance        # Specialized BCS wrapper
    └─> claude.x -T leet     # Uses agent system + BCS prompts

agents/leet                  # Leet agent wrapper
    └─> shlock → claude.x -T leet  # With session locking + BCS directory

agents/draa                  # Applied Anthropology wrapper
    └─> shlock → claude.x -T draa  # With session locking
```

### Agent System Flow

1. **Agent Discovery**: `claude.x` checks bundled `agents/Agents.json` first, falls back to `locate`
2. **Agent Loading**: `-T AGENT` flag triggers case-insensitive lookup in Agents.json
3. **System Prompt Injection**: Agent's `systemprompt` field passed via `--append-system-prompt`
4. **Knowledge Base Loading**: Files in `knowledgebase` array are read and appended as additional system prompts
5. **Execution**: Final `exec claude` with combined configuration

### Critical File Paths

- **BCS Reference**: `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md`
- **BCS Summary**: `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.summary.md` (used by agent wrappers)
- **Agent Config**: Bundled at `agents/Agents.json`, fallback via `locate -b '\Agents.json'`
- **Canonical Template**: `CLAUDE.canonical.md` (source for project initialization)

## Key Implementation Details

### claude.x Command Construction

The script builds a command array dynamically:

```bash
# Default configuration
claude_cmd=(
  --allowedTools Read Write Edit Bash
  --permission-mode acceptEdits
  --dangerously-skip-permissions
)

# Agent loading adds:
--append-system-prompt "Agent systemprompt content"
--append-system-prompt "$(cat knowledgebase_file)"

# System prompt options:
# --system-prompt replaces default prompt entirely (CLAUDE.md files ignored)
# --append-system-prompt adds to default prompt (CLAUDE.md files still loaded)
--system-prompt TEXT              # Replace default prompt (CLAUDE.md ignored)
--system-prompt-file FILE         # Replace default prompt from file
--append-system-prompt TEXT       # Append to default prompt (CLAUDE.md loaded)
--append-system-prompt-file FILE  # Append to default prompt from file

# Default directories:
--add-dir $HOME /tmp /ai /usr/local/ /usr/share

# Smart conversation continuation (auto-detects existing conversations):
# - Auto-continue if conversation exists for current directory
# - Start fresh otherwise
# - Override with --new or --continue
```

### Script Metadata Pattern

All bash scripts follow this structure (BCS requirement):
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='x.y.z'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**IMPORTANT**: Use `realpath --` not `readlink -en` (BCS compliance)

### Argument Parsing Strategy

`claude.x` uses sophisticated parsing:
- Recognizes own options: `-T`, `-n`, `-c`, `-v`, `-q`, `--help`, `--version`
- Passes through unknown options to claude CLI
- Disaggregates combined short options: `-vT` → `-v -T`
- Non-option arguments trigger `--print` mode for one-shot queries
- Uses `||:` pattern for safe conditional execution with `set -e`

### Session Locking (Agent Wrappers)

`agents/leet` and `agents/draa` use `shlock` for session locking:
```bash
# Prevents concurrent sessions per directory
shlock "$lockname"-leet -- claude.x -T leet "$@"

# Steal lock from another session
agents/leet --steal

# Optional logging to /var/log/{agent}.log
# Setup with: sudo agents/leet --setup
```

### Max Output Tokens

Agent wrappers export `CLAUDE_CODE_MAX_OUTPUT_TOKENS`:
```bash
# Default: 32000
declare -ix CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000

# Extended mode (-M/--maxtokens): 64000
agents/leet -M "Generate comprehensive output"
```

## Development Commands

### Script Validation

```bash
# Check BCS compliance with shellcheck
shellcheck claude.x claude.init claude.update agents/*

# Use BCS compliance agent for detailed analysis
agents/bcs-compliance "Check claude.init for BCS compliance"

# Test agent loading with verbose output
./claude.x -vv -T leet --help  # Shows loaded configuration

# Verify script metadata
grep -E '^(VERSION|SCRIPT_PATH|SCRIPT_DIR|SCRIPT_NAME)=' claude.x
```

### Running Scripts

```bash
# Run claude.x with different agents
./claude.x                              # Default (no agent)
./claude.x -T leet                      # Leet agent
./claude.x -T trans "translate query"   # Translation agent

# Custom system prompts
./claude.x --system-prompt "You are a Python expert"
./claude.x --system-prompt-file ~/prompts/expert.txt
./claude.x --append-system-prompt-file ~/prompts/rules.md

# Run specialized wrappers
agents/leet                             # Leet with BCS context
agents/bcs-compliance                   # BCS compliance expert

# Initialize new project
cd /path/to/project
/ai/scripts/claude/claude.init          # Prompts for existing files
/ai/scripts/claude/claude.init -C       # Force overwrite without prompts (--clobber)
/ai/scripts/claude/claude.init -u       # Run claude update first

# Update Claude CLI
./claude.update                         # Runs sudo claude update
```

### SDK Testing

```bash
cd sdk/

# Install dependencies first
pip install -r requirements.txt
# Or: pip install claude-agent-sdk rich

# Basic query test
python basic.py

# Custom tools test
python custom-tools.py

# Built-in tools test (creates greeting.txt)
python inbuild-tools.py
test -f greeting.txt && echo "Success"

# Agent options test (creates test/ directory)
python agent-options.py
test -d test && echo "Success"
```

### Agent Wrapper Testing

```bash
# Test leet agent wrapper
agents/leet --help

# Test BCS compliance agent
agents/bcs-compliance "Check claude.init for compliance"

# Test agent element extraction
agents/get-agent-element leet systemprompt
```

## Agent Wrapper Scripts

The repository includes specialized agent wrappers in `agents/`:

### Symlink-Based Architecture

Agents use symlinks to `claude.agent` (v1.0.0), which resolves agent configuration from the symlink name:
```bash
leet  -> claude.agent     # Resolves 'leet' from Agents.json
draa  -> claude.agent     # Resolves 'draa' from Agents.json
trans -> claude.agent     # Translation agent
sarki -> claude.agent     # Sarcastic Jakarta assistant
```

### Agent Options
```bash
agents/leet [OPTIONS] [PROMPT]
# Options: -n/--new, -c/--continue, -s/--steal, -M/--maxtokens, --setup
# Automatically adds BCS directory and system prompt
# Uses shlock for session locking per directory
```

### Available Agents
- **leet** - BCS-aware coding assistant with session locking
- **draa** - Applied Anthropology expert (evolution, secular dharma, cultural development)
- **trans** - Translation agent
- **sarki** - Sarcastic Jakarta assistant

### Utility Scripts
```bash
# Extract elements from Agents.json
agents/leet/get-agent-element AGENT_TAG [FIELD]
# Example: agents/leet/get-agent-element leet systemprompt

# Sync agent symlinks
agents/sync-agents-json
```

### Agent Test Suite
```bash
# Run all tests
agents/tests/run_tests.sh

# Individual test files
agents/tests/test_argument_parsing.sh
agents/tests/test_build_command.sh
agents/tests/test_agent_resolution.sh
agents/tests/test_integration.sh
```

## .gitignore Management

`claude.init` automatically manages .gitignore with:
```bash
echo CLAUDE.md >>.gitignore
echo .gudang >>.gitignore
echo BASH-CODING-STANDARD.md >>.gitignore
remblanks <.gitignore | sort -u >.gitignore2
mv .gitignore2 .gitignore
```

**Requires**: `remblanks` utility in PATH

## SDK Architecture

### Async Pattern

All SDK examples use asyncio:
```python
async def main():
    async for message in query(prompt="..."):
        print(message)

asyncio.run(main())
```

### Custom Tool Creation

Tools follow this pattern:
```python
@tool("tool_name", "Description", {"param": type})
async def tool_function(args: dict[str, Any]) -> dict[str, Any]:
    return {
        "content": [{
            "type": "text",
            "text": "Result"
        }]
    }
```

MCP server creation:
```python
server = create_sdk_mcp_server(
    name="server-name",
    version="1.0.0",
    tools=[tool1, tool2]
)
```

Tool naming: `mcp__{server_name}__{tool_name}`

## Dependencies

### Required Commands
- `jq` - JSON processing for agent system
- `locate` - Agent discovery fallback (requires updatedb)
- `realpath` - Path resolution (BCS requirement)
- `claude` - Claude Code CLI

### Optional Commands
- `remblanks` - .gitignore cleanup in claude.init
- `shlock` - Session locking for agent wrappers (leet, draa)
- `shellcheck` - Shell script linting

### Python Dependencies (SDK)
```bash
pip install claude-agent-sdk rich
```

## Color Output Convention

Scripts use these color codes when stderr is TTY:
```bash
RED=$'\033[0;31m'   # Error messages (✗)
CYAN=$'\033[0;36m'  # Info messages (◉)
NC=$'\033[0m'       # Reset
```

Utility functions:
```bash
info() { ((VERBOSE)) || return 0; >&2 echo "$SCRIPT_NAME: ${CYAN}◉${NC} $*"; }
error() { >&2 echo "$SCRIPT_NAME: ${RED}✗${NC} $*"; }
die() { (($#>1)) && error "${@:2}"; exit "${1:0}"; }
```

## Coding Principles

- **K.I.S.S.** - Keep implementations simple
- **"The best process is no process"** - Minimize unnecessary steps
- **"Everything should be made as simple as possible, but not any simpler"**

## Code Style

### Shell Scripts
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -euo pipefail`
- Shell options: `shopt -s inherit_errexit shift_verbose extglob nullglob`
- Indentation: 2 spaces (!!important)
- Variable declarations: Use `declare` or `local` statements
- Conditionals: Prefer `[[` over `[`
- Simple conditionals: Prefer `((...)) && ...` over `if...then`
- Integer increment: NEVER use `((i++))`, `((++i))`, or `((i+=1))` - declare as integer first (`local -i`), then use standalone `i+=1`
- End marker: `#fin` with blank linefeed

### Python
- Import order: standard lib, third-party, local modules
- Constants: UPPER_CASE at top of files
- Docstrings for functions
- End marker: `\n#fin\n`

### Error Handling
- Python: try/except with logging
- Shell: Proper exit codes and error messages

## Documentation Icons

When writing documentation:
- ◉ Info
- ⦿ Debug
- ▲ Warning
- ✓ Success
- ✗ Error

## Environment

- Ubuntu 24.04.3
- Bash 5.2.21
- Python 3.12.3
- Node.js v22.x LTS (for Claude Code)

## Common Patterns

### exec Usage

Both `claude.init` and `claude.x` use `exec` to replace the current process:
```bash
exec claude.x        # In claude.init
exec claude "${claude_cmd[@]}"  # In claude.x
```

**Implication**: No code runs after exec - it's the final command

### Array Building

Build command arrays incrementally:
```bash
local -a claude_cmd=(--initial-options)
claude_cmd+=(--added-option)
((condition)) && claude_cmd+=(--conditional-option)
```

Quote array expansions: `"${array[@]}"`

### Case-Insensitive Matching

Agent lookup uses:
```bash
agent_key=$(jq -r 'keys[]' "$agents_json" | grep -i "^$agent_tag" | head -n1)
```

### Safe Conditional with set -e

Use `||:` suffix for safe conditionals:
```bash
((VERBOSE)) && info "message" || :
[[ condition ]] && action || :
```

## Skills System

The `skills/` directory contains comprehensive documentation for building Claude Code skills:

- **00-README.md** - Skills system overview
- **01-Overview.md** - Conceptual introduction
- **02-SKILL-Format-Specification.md** - Detailed format spec
- **03-Architecture-Progressive-Disclosure.md** - Architecture patterns
- **04-Installation-Setup.md** - Setup guide
- **05-API-Integration.md** - API integration
- **06-Best-Practices.md** - Development best practices
- **07-Security-Permissions.md** - Security guidelines
- **08-Example-Skills-Catalog.md** - Example catalog
- **09-Skills-vs-MCP.md** - Skills vs MCP comparison
- **10-Limitations-Constraints.md** - Known limitations
- **11-Quick-Reference.md** - Quick reference

**Note**: `skills/repos/` contains skill examples but is gitignored.

## Enterprise Deployment (enterprise/)

The `enterprise/` directory contains enterprise deployment scripts.

### Deployment Scripts
| Script | Version | Purpose |
|--------|---------|---------|
| `claude.setup-machine` | 1.5.0 | Enterprise setup (groups, dirs, templates, MCP) |
| `claude.add-user` | 1.5.0 | Add user to claude-users group |
| `claude.fix-permissions` | 1.4.0 | Reset permissions on enterprise/user directories |
| `claude.cascade` | 1.2.0 | Display CLAUDE.md hierarchy |

### Two-Tier Architecture
```
/etc/claude-code/                    # Enterprise (all users)
├── CLAUDE.md                        # Enterprise policies (highest priority)
├── managed-mcp.json                 # MCP server configuration
└── .claude/
    ├── agents/                      # Shared agent definitions
    ├── commands/                    # Shared commands
    └── rules/                       # Enterprise rules (enforced)

~/.claude/                           # User (per-user, auto-created)
├── settings.json                    # User settings
├── rules/                           # User rules
└── ...
```

### Permissions Model
- **Enterprise** (`/etc/claude-code/`): `root:claude-users`, dirs `2775` (setgid), files `664`
- **User** (`~/.claude/`): `USER:GROUP`, dirs `755`, files `644`, credentials `600`

### Usage
```bash
# Enterprise setup on new server
sudo ./enterprise/claude.setup-machine

# Add user to Claude Code
sudo ./enterprise/claude.add-user USERNAME
sudo ./enterprise/claude.add-user USERNAME --init-config      # Pre-initialize ~/.claude/
sudo ./enterprise/claude.add-user USERNAME --copy-oauth FILE  # Share OAuth session

# Fix permissions
sudo ./claude.fix-permissions                # Enterprise directory
sudo ./claude.fix-permissions --user biksu   # User directory
```

## Bash Completion

Bash completion support is available in `.bash_completion`:
```bash
# Source in your shell
source /ai/scripts/claude/.bash_completion

# Provides completion for claude.init options: -h --help --version
```

## Project Documentation

Additional detailed documentation in `docs/`:
- **claude.x.md** - Comprehensive claude.x documentation
- **claude.init.md** - Project initialization guide
- **SDK.md** - Complete SDK reference and examples

## Backups and Checkpoints

- Use `checkpoint -q` for backups
- Location: `~/.checkpoint/{codebase_dir}/{YYYYMMDD_hhmmss}/`
- `.gudang` directories are project-specific data, normally ignored

## Conversation Persistence

Conversations are stored per-directory:
```bash
# Location: ~/.claude/projects/{dir-path}/
# Directory name derived from PWD with slashes replaced by dashes

# Check if conversation exists (used by claude.x auto-detection)
has_conversation() {
  local project_dir="${PWD//\//-}"
  local project_path="$HOME"/.claude/projects/"$project_dir"
  [[ -d "$project_path" ]] && compgen -G "$project_path"/*.jsonl >/dev/null 2>&1
}
```

#fin
