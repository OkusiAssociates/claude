think hard: Examine the @ARGUMENTS script and create a plan to bring it into compliance with the coding standard in @BASH-CODING-STANDARD.md

Use `bcscheck <script>` if available to verify compliance.

## Key Compliance Points

- **Legacy variable names**: Change PRG0, PRGDIR, PRG to SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- **Arithmetic increments**: Use `i+=1` ONLY; NEVER use `((i++))` or `((++i))`
- **Exit codes**: Use BCS0602 canonical exit codes (0=success, 1=general, 2=usage, 3=noent, etc.)
- **Shebang**: Use `#!/usr/bin/env bash`
- **Strict mode**: `set -euo pipefail` is mandatory
- **End marker**: `#fin` is mandatory

Do not over-engineer; if standard variables and functions are not required for the operation of the script, then do not include them.
