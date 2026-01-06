
## Coding Principles
  - K.I.S.S.
  - "The best process is no process"
  - "Everything should be made as simple as possible, but not any simpler."

## Code Style
- Python: 
  - Import order: standard lib, third-party, local modules
  - Constants: Define at top of files, use UPPER_CASE
  - Use descriptive function and variable names
  - Docstrings for functions; comment complex logic sections
  - Always end scripts with '\n#fin\n' to indicate the end of script

- Shell scripts:
  - Shebang `#!/bin/bash`
  - Always `set -euo pipefail` at start for error handling, unless there is a good reason not to do this.
  - 2-space indentation !!important
  - Always declare variables before use; use local within functions
  - Use descriptive variable names with `declare` or `local` statements
  - Prefer `[[` over `[` for conditionals
  - Prefer `((...)) && ...` or `[[...]] && ...` for simple conditionals over `if...then`
  - Use integer values where appropriate, and always declare with `-i`
  - Always use `var+=1`; never `((var++))`, `((var+=1))`, or `((++var))` - the post-increment returns the original value which can cause non-zero exit codes with `set -e`
  - Always end scripts with line '#fin' to indicate end of script, with a blank linefeed at the end
  - If it is necessary to refer to BASH-CODING-STANDARD.md, always use the form [BASH-CODING-STANDARD](https://github.com/Open-Technology-Foundation/bash-coding-standard)

- PHP:
  - Always use 2-space indent
  - Always use <?=...?> where possible for simple output; never <?php echo ...?>
  - Follow PSR-12 coding standards
  - Use prepared statements for all database queries
  - Always check array keys with isset() before accessing
  - Filter user inputs with filter_input() functions
  - Sanitize output with htmlspecialchars() or similar
  - Always check file operations for errors
  - Use proper HTTP status codes for errors

- JavaScript:
  - Use ES6+ syntax and features
  - Avoid jQuery where possible, use modern DOM APIs
  - Follow Bootstrap patterns for UI components, unless there is a good reason to do otherwise
  - Always sanitize dynamic content before insertion
  - Use strict mode ('use strict'), unless there is a good reason to do otherwise

- Error handling:
  - Python: Use try/except with logging
  - Shell: Use proper exit codes and error messages

- Environment:
  - Python venvs: Activate with `source <dir>/.venv/bin/activate`
  - Use MySQL or Sqlite3 database for data storage, as appropriate

## Developer Tech Stack
  - Ubuntu 24.04.3
  - Bash 5.2.21
  - Python 3.12.3
  - Apache2 2.4.58
  - PHP 8.3.6
  - MySQL 8.0.44
  - SQLite3 3.45.1
  - Bootstrap 5.3
  - FontAwesome

## Hardware
- Development Machine (hostname 'okusi'):
  - model: Lenovo Legion i9
  - gpu: GEForce RTX
  - system memory: 32GB

- Production Machine (hostname 'okusi3'):
  - model: Intel Xeon Silver 4410Y, 2 cpu
  - gpu: NVIDIA L4
  - system memory: 256GiB

## Backups and Code Checkpoints
- Use `checkpoint -q` for checkpoint backups. 
- checkpoint backups are located in ~/.checkpoint/{codebase_dir}/{YYYYMMDD_hhmmss}/
- .gudang directories should normally be ignored.

