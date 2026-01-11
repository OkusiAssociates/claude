# claude.init - Project Initialization Script

## Overview

`claude.init` is an initialization script that sets up a new project directory with Claude Code configuration files and launches an interactive session.

**File:** `/ai/scripts/claude/claude.init`
**Version:** 1.0.3
**Lines:** 54

## Purpose

Streamline the initialization of Claude Code in a new project by:
1. Updating Claude to the latest version
2. Creating necessary directory structure
3. Setting up Bash Coding Standard references
4. Initializing or updating CLAUDE.md configuration
5. Configuring .gitignore appropriately
6. Launching claude.x

## Key Features

### 1. Automatic Claude Update

Ensures you're running the latest version before starting:
```bash
sudo claude update
```

### 2. Project Structure Creation

Creates `.gudang` directory for project-specific data:
```bash
mkdir -p .gudang
```

**◉ Info:** `.gudang` is automatically added to .gitignore

### 3. BCS Integration

Creates symlink to Bash Coding Standard:
```bash
ln -fs /ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md BASH-CODING-STANDARD.md
```

**Purpose:** Provides consistent access to BCS documentation across projects

### 4. CLAUDE.md Management

Handles initialization or updating of CLAUDE.md:

**For New Projects:**
- Prompts for confirmation
- Copies canonical CLAUDE.md template

**For Existing Projects:**
- Detects existing CLAUDE.md
- Offers to append canonical information
- Preserves existing content

### 5. .gitignore Management

Automatically updates .gitignore with:
- `CLAUDE.md` entry
- `BASH-CODING-STANDARD.md` entry
- `.gudang` directory entry

**◉ Info:** Removes duplicates and blank lines automatically

## Usage

### Basic Usage

```bash
cd /path/to/new/project
/ai/scripts/claude/claude.init
```

### With Help

```bash
/ai/scripts/claude/claude.init --help
# Output: claude.init 1.0.3 - Create canonical CLAUDE.md in current directory
```

### Quick Alias

Add to your `~/.bashrc`:
```bash
alias claude-init='/ai/scripts/claude/claude.init'
```

Then use:
```bash
cd /path/to/project
claude-init
```

## Interactive Prompts

### New Project Initialization

When CLAUDE.md doesn't exist:
```
Init claude in /home/user/myproject? y/n
```

**Response:**
- `y` - Copies CLAUDE.canonical.md to ./CLAUDE.md
- `n` - Skips CLAUDE.md creation
- Other - Skips CLAUDE.md creation

### Existing Project Update

When CLAUDE.md already exists:
```
CLAUDE.md already exists in /home/user/myproject.
Append canonical info? y/n
```

**Response:**
- `y` - Appends CLAUDE.canonical.md to existing CLAUDE.md
- `n` - Leaves existing CLAUDE.md unchanged
- Other - Leaves existing CLAUDE.md unchanged

**◉ Info:** The append operation uses `cat -s` to squeeze multiple blank lines

## Files Created/Modified

### Created Files

1. **CLAUDE.md** (if new project)
   - Location: `./CLAUDE.md`
   - Source: `/ai/scripts/claude/CLAUDE.canonical.md`
   - Purpose: Project-specific Claude instructions

2. **BASH-CODING-STANDARD.md** (symlink)
   - Location: `./BASH-CODING-STANDARD.md`
   - Target: `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md`
   - Purpose: BCS reference documentation

3. **.gudang/** (directory)
   - Location: `./.gudang/`
   - Purpose: Project data storage

### Modified Files

1. **.gitignore**
   - Adds: `CLAUDE.md`, `BASH-CODING-STANDARD.md`, `.gudang`
   - Removes: Duplicate entries and blank lines
   - Sorted: Alphabetically

2. **CLAUDE.md** (if appending)
   - Appends: Content from CLAUDE.canonical.md
   - Preserves: Original content

## Implementation Details

### Script Structure

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.3'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_NAME=${SCRIPT_PATH##*/}
SCRIPT_DIR=${SCRIPT_PATH%/*}

main() {
  # Handle help/version flags
  # Update claude
  # Create .gudang directory
  # Create BCS symlink
  # Handle CLAUDE.md initialization/append
  # Update .gitignore
  # Launch claude.x
}

main "$@"
#fin
```

### Execution Flow

```
┌─────────────────────────┐
│ Start claude.init       │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Check help/version flag │
└───────────┬─────────────┘
            │ no flag
            ▼
┌─────────────────────────┐
│ sudo claude update      │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ mkdir -p .gudang        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Create BCS symlink      │
│ (if not exists)         │
└───────────┬─────────────┘
            │
            ▼
      ┌─────┴─────┐
      │ CLAUDE.md │
      │  exists?  │
      └─────┬─────┘
            │
      ┌─────┴──────┐
      │            │
     yes          no
      │            │
      ▼            ▼
┌──────────┐  ┌──────────┐
│ Prompt   │  │ Prompt   │
│ append?  │  │ init?    │
└────┬─────┘  └────┬─────┘
     │             │
     │ y           │ y
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Append   │  │ Copy     │
│ canonical│  │ canonical│
└────┬─────┘  └────┬─────┘
     │             │
     └──────┬──────┘
            │
            ▼
┌─────────────────────────┐
│ Update .gitignore       │
│ - Add entries           │
│ - Remove blanks         │
│ - Sort unique           │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ exec claude.x           │
└─────────────────────────┘
```

### Key Operations

#### 1. BCS Symlink Creation

```bash
if [[ ! -f BASH-CODING-STANDARD.md ]]; then
  [[ -L BASH-CODING-STANDARD.md ]] || \
    ln -fs /ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md \
           BASH-CODING-STANDARD.md
  echo BASH-CODING-STANDARD.md >>.gitignore
fi
```

**Logic:**
- Skip if regular file exists
- Create symlink if not a link
- Add to .gitignore

#### 2. CLAUDE.md Handling

**Existing File:**
```bash
if [[ -f ./CLAUDE.md ]]; then
  echo "CLAUDE.md already exists in $PWD."
  read -r -n 1 -p 'Append canonical info? y/n '
  [[ ${REPLY,,} == y ]] && \
    cat -s "$SCRIPT_DIR"/CLAUDE.canonical.md >> ./CLAUDE.md || true
fi
```

**New File:**
```bash
else
  read -r -n 1 -p "Init claude in $PWD? y/n "
  [[ ${REPLY,,} == y ]] && \
    cp -p "$SCRIPT_DIR"/CLAUDE.canonical.md ./CLAUDE.md || true
fi
```

**◉ Info:** Uses `${REPLY,,}` for case-insensitive comparison

#### 3. .gitignore Management

```bash
echo CLAUDE.md >>.gitignore
echo .gudang >>.gitignore
remblanks <.gitignore | sort -u >.gitignore2
mv .gitignore2 .gitignore
```

**Process:**
1. Append entries (may create duplicates)
2. Remove blank lines with `remblanks`
3. Sort and remove duplicates with `sort -u`
4. Replace original

**▲ Warning:** Requires `remblanks` utility to be in PATH

#### 4. Launch claude.x

```bash
exec claude.x
```

**◉ Info:** Uses `exec` to replace current process - no return to script

## CLAUDE.canonical.md Content

The canonical template includes:

### Coding Principles
- K.I.S.S.
- "The best process is no process"
- Simplicity guidelines

### Code Style Guidelines

**Bash:**
- Shebang requirements
- Error handling with `set -euo pipefail`
- 2-space indentation
- Variable declaration practices
- Conditional preferences
- End marker: `#fin`

**Python:**
- Import order
- Constant naming
- Documentation requirements
- Virtual environment usage

**PHP:**
- PSR-12 standards
- Security practices
- Database query safety

**JavaScript:**
- ES6+ syntax
- Modern DOM APIs
- Bootstrap patterns
- Strict mode

### Environment Details
- Ubuntu 24.04.3
- Bash 5.2.21
- Python 3.12.3
- Apache2 2.4.58
- PHP 8.3.6
- MySQL 8.0.43
- SQLite3 3.45.1
- Bootstrap 5.3
- FontAwesome

### Hardware Information
- Development and production machine specs
- GPU information
- Memory configuration

### Backup Information
- Checkpoint backup usage
- Backup location structure
- .gudang directory handling

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (help displayed) or claude.x launched |
| Non-zero | Failure from `sudo claude update` or `exec claude.x` |

## Dependencies

### Required Commands

- `bash` (5.2+)
- `sudo` - For Claude update
- `claude` - Claude Code CLI
- `mkdir` - Directory creation
- `ln` - Symlink creation
- `cat` - File concatenation
- `cp` - File copying
- `echo` - Output
- `read` - User input
- `remblanks` - Blank line removal
- `sort` - Sorting
- `mv` - File moving

### Required Files

- `/ai/scripts/claude/CLAUDE.canonical.md` - Template
- `/ai/scripts/Okusi/bash-coding-standard/BASH-CODING-STANDARD.md` - BCS docs
- `claude.x` - Must be in PATH or same directory

**▲ Warning:** Script will fail if CLAUDE.canonical.md is missing

## File Permissions

The script requires:
- **Read:** CLAUDE.canonical.md
- **Write:** Current directory (for .gudang, CLAUDE.md, .gitignore)
- **Execute:** sudo privileges (for claude update)

## Use Cases

### 1. New Project Initialization

```bash
mkdir ~/projects/myapp
cd ~/projects/myapp
/ai/scripts/claude/claude.init
```

**Result:**
- .gudang/ directory created
- CLAUDE.md initialized
- BASH-CODING-STANDARD.md symlink created
- .gitignore configured
- claude.x launched

### 2. Existing Project Setup

```bash
cd ~/projects/existing-app
/ai/scripts/claude/claude.init
```

**Result:**
- Appends canonical info to existing CLAUDE.md
- Updates .gitignore
- Launches claude.x

### 3. Multiple Project Setup

```bash
#!/bin/bash
for project in proj1 proj2 proj3; do
  mkdir -p "$project"
  cd "$project"
  echo -e 'y\n' | /ai/scripts/claude/claude.init
  cd ..
done
```

**◉ Info:** Pipes 'y' response for non-interactive initialization

## Troubleshooting

### remblanks Not Found

**Error:**
```bash
claude.init: line 45: remblanks: command not found
```

**Solutions:**
1. Install remblanks utility
2. Replace with alternative:
```bash
# Instead of: remblanks <.gitignore
grep -v '^[[:space:]]*$' .gitignore
```

### Permission Denied on sudo

**Error:**
```
sudo: claude update: command not found
```

**Cause:** Claude not installed or not in sudo PATH

**Solution:**
```bash
# Install Claude Code (native binary)
curl -fsSL https://claude.ai/install.sh | bash
# Or ensure /usr/local/bin is in secure_path for sudo
```

### CLAUDE.canonical.md Not Found

**Error:**
Script fails when trying to copy/append

**Solution:**
Verify SCRIPT_DIR is correct and file exists:
```bash
ls -l /ai/scripts/claude/CLAUDE.canonical.md
```

### BCS Symlink Fails

**Error:**
```
ln: failed to create symbolic link
```

**Cause:** No write permission in current directory

**Solution:**
```bash
chmod u+w .
```

### claude.x Not Found

**Error:**
```
claude.init: line 49: exec: claude.x: not found
```

**Solutions:**
1. Ensure claude.x is in PATH
2. Use absolute path in script
3. Add to PATH:
```bash
export PATH="/ai/scripts/claude:$PATH"
```

## BCS Compliance

**Current Status:** 80% compliant

**Strengths:**
- ✓ Proper shebang: `#!/usr/bin/env bash`
- ✓ Has `set -euo pipefail`
- ✓ Script metadata present
- ✓ Readonly declarations
- ✓ Proper `#fin` marker
- ✓ Uses `[[` for conditionals

**Issues:**
- ▲ Missing `shopt -s inherit_errexit shift_verbose extglob nullglob`
- ◉ Uses `|| true` pattern (acceptable but noted by shellcheck)

**See:** [BCS-COMPLIANCE-REPORT.md](../BCS-COMPLIANCE-REPORT.md) for details.

## Security Considerations

### sudo Usage

The script requires sudo for Claude update:
```bash
sudo claude update
```

**Implications:**
- User must have sudo privileges
- May prompt for password
- Runs with elevated permissions

### File Overwrite Risk

When appending to CLAUDE.md:
- Original content preserved
- No backup created automatically
- Consider manual backup before appending

### Symlink Security

Symlinks are created without verification:
- Target existence not checked
- Broken symlinks possible
- Symlinks can be replaced if running multiple times

## Best Practices

### 1. Version Control

Initialize git before running:
```bash
git init
/ai/scripts/claude/claude.init
```

**Benefit:** .gitignore is properly configured before first commit

### 2. Backup Before Append

```bash
cp CLAUDE.md CLAUDE.md.backup
/ai/scripts/claude/claude.init
```

### 3. Review .gitignore

After initialization:
```bash
cat .gitignore
```

Ensure all entries are appropriate for your project.

### 4. Customize CLAUDE.md

After initialization, edit CLAUDE.md to add:
- Project-specific guidelines
- API documentation locations
- Testing procedures
- Deployment instructions

## Related Files

- [claude.x](./claude.x.md) - Main wrapper (launched at end)
- [CLAUDE.canonical.md](../CLAUDE.canonical.md) - Template source
- [BCS](https://github.com/Open-Technology-Foundation/bash-coding-standard) - Coding standard

## Advanced Usage

### Non-Interactive Mode

For CI/CD or automated setup:
```bash
#!/bin/bash
# Simulate 'y' responses
{ echo 'y'; echo 'y'; } | /ai/scripts/claude/claude.init
```

### Custom Template

Use a custom CLAUDE.md template:
```bash
#!/bin/bash
# Modify claude.init or create wrapper
cp /path/to/custom/CLAUDE.md .
echo CLAUDE.md >> .gitignore
claude.x
```

### Skip Claude Update

If you don't want to update Claude:
```bash
# Edit script or create wrapper that skips line 21
sed -n '/sudo claude update/!p' /ai/scripts/claude/claude.init > ./my-init
chmod +x ./my-init
./my-init
```

## Source Code Reference

**Key Lines:**
- `claude.init:4` - Error handling setup
- `claude.init:7` - Script metadata
- `claude.init:21` - Claude update
- `claude.init:24` - .gudang creation
- `claude.init:27-30` - BCS symlink creation
- `claude.init:33-40` - CLAUDE.md handling
- `claude.init:43-46` - .gitignore management
- `claude.init:49` - claude.x launch

## Changelog

### Version 1.0.3
- Current stable version
- Interactive prompts for CLAUDE.md
- Automatic .gitignore management
- BCS symlink creation

## See Also

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Project Setup Guide](../README.md#quick-start)
- [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)

---

**Last Updated:** 2025-10-19

#fin
