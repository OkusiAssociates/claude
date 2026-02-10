# Bash 5.2+ Raw Code Audit

Perform a comprehensive audit of this Bash codebase targeting **Bash 5.2+ exclusively**. This is a raw code audit with no framework assumptions.

## Context Requirements

- **Bash Version**: 5.2+ only (modern features expected, no compatibility layers)
- **Coding Standard**: Check against Bash Coding Standard (BCS) if present
- **Code Style**: Raw shell scripts, no frameworks
- **Dependencies**: Minimal external dependencies, standard tools only

## 1. BCS Compliance (if applicable)

If `BASH-CODING-STANDARD.md` or `@BASH-CODING-STANDARD.md` exists in the project:

- Check for BCS compliance using `bcscheck` command (if available)
- Validate against all 12 BCS sections
- Reference specific BCS codes (format: BCS0102, BCS0205, etc.)
- Check template compliance (minimal/basic/complete/library patterns)
- Verify self-compliance for BCS-aware projects

### Mandatory Script Structure (BCS0101)
1. Shebang: `#!/usr/bin/env bash` (line 1)
2. ShellCheck directives (if needed)
3. Brief description comment
4. `set -euo pipefail` (mandatory, lines 4-6)
5. Required shopt: `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. Script metadata: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` with `declare -r`
7. Global variable declarations
8. Color definitions (if terminal output)
9. Utility functions (messaging, helpers)
10. Business logic functions
11. `main()` function (required for scripts >40 lines)
12. Script invocation: `main "$@"`
13. End marker: `#fin` (mandatory for scripts only)

## 2. ShellCheck Compliance

**Compulsory**: Run ShellCheck on all bash scripts

```bash
shellcheck -x script.sh
```

- Report all warnings and errors
- Validate documented disable directives (must have comments explaining why)
- Flag undocumented suppressions as violations
- Check for SC2015 violations (use explicit if/then, not `&&` `||` chains)

## 3. Bash 5.2+ Language Features

### Required Patterns
- `[[ ]]` for conditionals (NOT `[ ]`)
- `(( ))` for arithmetic (NOT `expr` or `$[]`)
- Process substitution: `< <(command)` over pipes to while loops
- `declare -n` nameref instead of `eval` for indirection
- `mapfile`/`readarray` for reading files into arrays
- `${var@Q}` for safe quoting when needed

### Forbidden/Deprecated Patterns
- Backticks (use `$()` instead)
- `expr` for arithmetic
- `eval` with user-controlled input (use `declare -n`)
- ALWAYS USE `i+=1`; NEVER `((i++))`, `((++i))`, `((i+=1))`
- Function keyword: `function name()` (use `name()` only)
- `test` or `[` (use `[[` instead)

## 4. Security Vulnerabilities

### Critical Security Checks

**Command Injection**
- Unsafe `eval` usage with user/variable input
- `eval` with unvalidated variable names
- Recommend `declare -n` nameref as safe alternative

**Path Traversal**
- Unvalidated `cd` operations
- Missing `realpath` validation before directory changes
- Symlink attack vectors

**Unsafe File Operations**
- `rm -rf` without variable validation
- Missing checks: `[[ -n "$var" && "$var" != "/" && "$var" != "." ]]`
- Wildcard usage without explicit paths: `rm *` vs `rm ./*`

**SUID/SGID Scripts**
- FORBIDDEN: Bash scripts must NEVER use SUID/SGID
- Flag any setuid/setgid permissions

**PATH Manipulation**
- Unsafe PATH modifications
- Missing PATH validation
- Recommend explicit tool paths or PATH locking

**Input Validation**
- Unvalidated user input in critical operations
- Missing argument validation (noarg pattern)
- Unsanitized input in SQL/command contexts

**Privilege Escalation**
- Unsafe sudo usage
- Group management in install scripts
- SGID directory creation without justification

## 5. Variable Handling & Quoting

### Variable Expansion (BCS0301-0303)
- Default: `"$var"` (no braces unless required)
- Use braces when: `"${var##pattern}"`, `"${var:-default}"`, `"${array[@]}"`, `"${var1}${var2}"`
- Always quote variables in conditionals: `[[ -f "$file" ]]`

### Quoting Rules (BCS0401-0402)
- Single quotes for static strings: `info 'Processing files'`
- Double quotes when variables needed: `info "Processing $count files"`
- Never unquoted variables (except in very specific contexts)

### Array Handling (BCS0501-0503)
- Proper array declaration: `declare -a array=()`
- Safe iteration: `for item in "${array[@]}"; do`
- Avoid string splitting as array simulation

### Boolean Flags (BCS0205)
- Pattern: `declare -i FLAG=0`
- Usage: `((FLAG)) && action`
- NOT: `if [[ "$FLAG" == "1" ]]`

### Readonly Variables (BCS0203)
- Group readonly declarations: `readonly -- VAR1 VAR2 VAR3`
- Place after variable initialization
- Use `--` separator

## 6. Function Organization & Design

### Function Structure (BCS0601-0606)
- Bottom-up organization (low-level functions first)
- Naming: `lowercase_with_underscores`
- Export with: `declare -fx function_name` (if needed)
- One purpose per function
- Clear return values (0=success, non-zero=error)

### Required Utility Functions (BCS0901)
```bash
_msg()      # Core messaging function
info()      # Info messages
warn()      # Warnings (>&2)
error()     # Errors (>&2)
die()       # Exit with error
vecho()     # Verbose output
debug()     # Debug messages
yn()        # Yes/no prompts
noarg()     # Argument validation
```

### main() Function (BCS0101)
- Required for scripts >40 lines
- All script logic inside main()
- Invoked as: `main "$@"`

## 7. Error Handling

### set -e Compliance (BCS0801)
- `set -euo pipefail` mandatory (lines 4-6)
- Exception: Dual-purpose scripts may conditionally set
- Check return values explicitly when needed: `command || { error "Failed"; return 1; }`

### Error Output (BCS0901)
- Redirect at beginning: `>&2 echo "error"`
- NOT at end: `echo "error" >&2`

### Trap Usage (BCS0806)
- Use EXIT trap for cleanup
- Proper trap syntax: `trap cleanup EXIT`

### Exit Codes (BCS0602)

BCS defines 25 canonical exit codes:

| Code | Name | Use Case |
|------|------|----------|
| 0 | SUCCESS | Successful termination |
| 1 | ERR_GENERAL | General/unspecified error |
| 2 | ERR_USAGE | Command line usage error |
| 3 | ERR_NOENT | No such file or directory |
| 4 | ERR_ISDIR | Is a directory (expected file) |
| 5 | ERR_IO | I/O error |
| 6 | ERR_NOTDIR | Not a directory (expected dir) |
| 7 | ERR_EMPTY | File/input is empty |
| 8 | ERR_REQUIRED | Required argument missing |
| 9 | ERR_RANGE | Value out of range |
| 10 | ERR_TYPE | Wrong type/format |
| 11 | ERR_PERM | Operation not permitted |
| 12 | ERR_READONLY | Read-only filesystem |
| 13 | ERR_ACCESS | Permission denied |
| 14 | ERR_NOMEM | Out of memory |
| 15 | ERR_NOSPC | No space left on device |
| 16 | ERR_BUSY | Resource busy/locked |
| 17 | ERR_EXIST | Already exists |
| 18 | ERR_NODEP | Missing dependency |
| 19 | ERR_CONFIG | Configuration error |
| 20 | ERR_ENV | Environment error |
| 21 | ERR_STATE | Invalid state/precondition |
| 22 | ERR_INVAL | Invalid argument |
| 23 | ERR_NETWORK | General network error |
| 24 | ERR_TIMEOUT | Operation timed out |
| 25 | ERR_HOST | Host unreachable/unknown |

**Reserved:** 64-78 (sysexits), 126 (cannot execute), 127 (not found), 128+n (signals)

## 8. Code Style & Best Practices

### Formatting (BCS1301)
- Indentation: 2 spaces (never tabs)
- Line length: 100 characters (except URLs/paths)
- One command per line (except simple `&&` chains)

### Comments (BCS1302)
- Explain WHY, not WHAT
- Document non-obvious logic
- Comment complex regex patterns
- Explain security-critical sections

### Naming Conventions (BCS1303)
- Constants: `UPPER_CASE`
- Functions: `lowercase_with_underscores`
- Local variables: `lower_case`
- Private functions: `_leading_underscore`

## 9. Dual-Purpose Scripts (BCS0102)

For scripts that can be both executed and sourced:

```bash
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  # Sourced mode - skip set -e, export functions
  declare -fx function_name
else
  # Executed mode - enable strict mode
  set -euo pipefail
  main "$@"
fi
```

## 10. Testing

- Test file structure and organization
- Use of test helpers/assertions
- Coverage of critical functions
- ShellCheck in test pipeline
- Test isolation and cleanup

## 11. Performance Issues

### Subprocess Spawning
- Excessive command substitution `$()`
- Find operations in loops
- Repeated command execution (cache results)

### File I/O
- Multiple reads of same file
- Inefficient text processing
- Missing use of bash built-ins

### Bash Built-ins vs External Commands
- Prefer bash built-ins when available
- Consider loadable builtins for performance-critical paths
- Document why external commands are necessary

## 12. FHS Compliance & Installation

For installed scripts:
- Search paths: script dir → `/usr/local/share/` → `/usr/share/`
- Proper use of `PREFIX` variable
- Makefile security (no unsafe privilege escalation)
- Group/permission management (justify SGID)

## Output Format

For each issue found:

1. **Severity**: Critical/High/Medium/Low
2. **Location**: `file.sh:line_number`
3. **BCS Code**: Reference if applicable (e.g., BCS0102)
4. **Description**: Clear explanation of the issue
5. **Impact**: How this affects the script/system
6. **Recommendation**: Concrete fix with Bash 5.2+ syntax

## Executive Summary

Provide:
- **Overall Health Score**: X/10 with justification
- **Top 5 Critical Issues**: Immediate attention required
- **Quick Wins**: Low-effort, high-impact improvements
- **Long-term Recommendations**: Architectural improvements
- **ShellCheck Results**: Summary of findings
- **BCS Compliance**: Overall compliance percentage (if applicable)

## Tool Integration

Run these tools automatically:

```bash
# ShellCheck (compulsory)
shellcheck -x script.sh

# BCS check (if bcscheck command available)
bcscheck script.sh

# Optional: Test suite
./tests/run-all-tests.sh
```

## Save Results

Save the complete audit report to:

```
./AUDIT-BASH.md
```

Include:
- Date and auditor information
- File statistics (total lines, functions, scripts)
- Complete findings organized by severity
- Tool output summaries
- Actionable recommendations with code examples
