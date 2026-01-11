---
name: okusi
description: Context about Gary Dean (aka, Biksu Okusi) and Okusi Group for projects involving Indonesian business operations, BCS-compliant bash scripting, and technical documentation
allowed-tools: [Read, Write, Edit, Bash]
metadata:
  author: Gary Dean
  company: Okusi Group
  version: 1.0.0
  updated: 2025-10-19
---

# Okusi Context and Standards

This skill provides context about Gary Dean, Okusi Group, and technical standards when working on related projects.

## About Gary Dean (Biksu Okusi)

**Gary Dean** is an Australian-Indonesian technology professional and entrepreneur based in Bali, Indonesia.

### Background
- **Origin**: Raised in Perth, Western Australia
- **Migration**: Moved to Indonesia in 1996
- **Personal**: Gemini, Rooster, INFJ, blood type B-, ASD-1 (Asperger's)
- **Website**: [garydean.id](https://garydean.id)

### Education
- **1996-2000**: Bachelor of Asian Studies - Murdoch University
- **1995-1996**: Diploma of Social Science (Indonesian) - Central Institute of Technology
- **1981-1982**: Certificates in Animal Technology and Animal Nursing - Bentley Technical College

### Professional Roles
- **Founder/Chairman**: Okusi Group (corporate services for Indonesian direct investment companies)
- **Director**: Multiple Indonesian companies across various sectors
- **Founder** (2013): Yayasan Teknologi Terbuka Indonesia (Indonesian Open Technology Foundation)

## About Okusi Group

Okusi Group provides corporate services for Indonesian direct investment companies, focusing on:
- Corporate governance and compliance
- Technology infrastructure and solutions
- Open source technology advocacy
- Business process optimization

### Core Philosophy
- **K.I.S.S.** - Keep It Simple, Stupid
- **"The best process is no process"** - Minimize unnecessary steps
- **"Everything should be made as simple as possible, but not any simpler"** (Einstein)

## Technical Standards

### Bash Coding Standard (BCS)

All bash scripts must adhere to the Bash Coding Standard located at:
`/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md`

**Key Requirements:**
```bash
#!/bin/bash
#shellcheck disable=...# if required
# Short description of script
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='x.y.z'
declare -r SCRIPT_PATH=$(realpath -e -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Important BCS Rules:**
- Use `realpath -e` not `readlink -en`
- 2 spaces indentation (!!important)
- Prefer `[[` over `[`
- Simple conditionals: `((...)) && ...` over `if...then`
- Integer increment: `((var+=1))` not `((var++))` (avoid non-zero exit with set -e)
- End scripts with `#fin` and blank linefeed
- Use `declare` or `local` for variable declarations
- Quote array expansions: `"${array[@]}"`
- Safe conditionals with set -e: use `||:` suffix

**Utility Functions Pattern:**
```bash
if [[ -t 2 ]]; then
  declare -r RED=$'\033[0;31m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' CYAN='' NC=''
fi

info() { ((VERBOSE)) || return 0; >&2 echo "$SCRIPT_NAME: ${CYAN}◉${NC} $*"; }
error() { >&2 echo "$SCRIPT_NAME: ${RED}✗${NC} $*"; }
die() { (($#>1)) && error "${@:2}"; exit "${1:0}"; }
```

### Documentation Standards

**Standard Icons:**
- **◉** Info
- **⦿** Debug
- **▲** Warning
- **✓** Success
- **✗** Error

**README.md Requirements:**
- Do NOT mention files listed in `.gitignore`
- Keep documentation focused on tracked files only
- Use clear section headers
- Include practical examples

**Code Comments:**
- Focus on "why" not "what"
- Document non-obvious logic
- Include usage examples where helpful

### Shell Script Style

**Preferred Patterns:**
```bash
# Good: Simple conditional with arithmetic
((VERBOSE)) && info "message" || :

# Good: Array building
local -a cmd=(--initial-options)
cmd+=(--added-option)
((condition)) && cmd+=(--conditional-option)

# Good: Safe conditional with set -e
[[ condition ]] && action || :

# Good: Readonly arrays when not modified
declare -ar CONSTANTS=(value1 value2)

# Good: exec for process replacement
exec command "${args[@]}"
```

**Avoid:**
```bash
# Bad: Increment without handling set -e
((var++))

# Bad: Unquoted array expansion
echo ${array[@]}

# Bad: Using [ instead of [[
if [ "$var" = "value" ]; then

# Bad: readlink instead of realpath
SCRIPT_PATH=$(readlink -en "$0")
```

### Python Style

```python
# Import order: standard lib, third-party, local
import asyncio
from typing import Any

# Constants at top
VERSION = "1.0.0"

# Docstrings for functions
def function_name(args: dict[str, Any]) -> dict[str, Any]:
    """Brief description.

    Args:
        args: Description

    Returns:
        Description
    """
    pass

# End marker
#fin
```

### Error Handling

**Bash:**
```bash
# Use die() function for fatal errors
[[ -f "$required_file" ]] || die 1 "Required file not found ${required_file@Q}"

# Proper exit codes
# 0 = success
# 1 = general error
# 22 = invalid argument (EINVAL)
```

**Python:**
```python
try:
    operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise
```

## Indonesian Context

### Language
- Biksu Okusi is fluent in Indonesian (Bahasa Indonesia)
- Has formal education in Indonesian language and Asian Studies
- Deep understanding of Indonesian business culture and practices

### Business Environment
- Focus on direct investment companies (PMA - Penanaman Modal Asing)
- Understanding of Indonesian corporate law and compliance
- Experience with Indonesian government processes and bureaucracy

## Communication Preferences

### Style
- **Direct and concise** - no unnecessary verbosity
- **Technical accuracy** over politeness
- **Objective** - facts and problem-solving focused
- **No emojis** unless explicitly requested
- **Professional but casual** - avoid corporate jargon

### Documentation
- **Practical examples** over theoretical explanations
- **Clear structure** with headers and sections
- **Markdown formatting** for CLI/terminal output
- **Code comments** should explain "why" not "what"

## Working Environment

### Tech Stack
- **OS**: Ubuntu 24.04.3 LTS
- **Shell**: Bash 5.2.21
- **Python**: 3.12.3
- **Node.js**: v22.x LTS
- **Primary Editor**: Claude Code CLI

### Directory Structure Conventions
- **Scripts**: `/ai/scripts/`
- **BCS Location**: `/ai/scripts/Okusi/bash-coding-standard/`
- **Working dirs**: `/home/sysadmin`, `/tmp`, `/ai`, `/usr/local/`, `/usr/share`
- **Backups**: `~/.checkpoint/{codebase_dir}/{YYYYMMDD_hhmmss}/`
- **Project data**: `.gudang/` (git-ignored)

## When to Use This Skill

Activate this skill when:
- Working on projects in Gary's directories (`/ai/scripts/`, `/home/sysadmin/`)
- Creating or reviewing bash scripts (ensure BCS compliance)
- Writing documentation for Gary's projects
- Working with Indonesian business context
- Creating technical solutions for Okusi Group
- Any task requiring understanding of Gary's preferences and standards

## Examples

### Bash Script Creation
When creating bash scripts:
1. Start with required BCS boilerplate
2. Use 2-space indentation
3. Include utility functions if needed
4. End with `#fin` marker
5. Run `shellcheck` for validation

### Documentation
When writing documentation:
1. Use standard icons (◉ ⦿ ▲ ✓ ✗)
2. Exclude `.gitignore` files from README
3. Focus on practical usage
4. Include command examples
5. Keep it concise and scannable

### Code Review
When reviewing code:
1. Check BCS compliance for bash scripts
2. Verify proper error handling
3. Ensure consistent style (2-space indentation)
4. Look for unsafe patterns (unquoted arrays, etc.)
5. Validate that comments explain "why"

#fin
