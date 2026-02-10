# Bash Coding Standard (BCS)

All Bash scripts must adhere to the BCS standard, internally and externally. BCS has **14 sections** covering script structure, variables, expansion, quoting, arrays, functions, control flow, error handling, I/O, arguments, files, security, style, and advanced patterns.

## Compliance Checking

Use `bcscheck <script>` to verify compliance against the standard.

## Tier Level Determination

The default tier level in a BCS-compliant system is determined by the symlink:

* **File**: `@BASH-CODING-STANDARD.md` or `BASH-CODING-STANDARD.md`
* **Possible targets**:
    - `.complete.md` (full standard)
    - `.summary.md` (summarized standard)
    - `.abstract.md` (high-level standard)
    - `.rulet.md` (condensed rule list)

The symlink indicates which tier of the BCS is being followed in that directory.

## BCS Location (FHS-Compliant Search Order)

1. Script directory (development mode)
2. `/usr/local/share/yatti/bash-coding-standard/data/` (local install)
3. `/usr/share/yatti/bash-coding-standard/data/` (system install)
4. `/ai/scripts/Okusi/bash-coding-standard/data/` (fallback)

Many repository directories will have BASH-CODING-STANDARD.md symlinks to:
`/ai/scripts/Okusi/bash-coding-standard/data/BASH-CODING-STANDARD{.complete,.summary,.abstract,.rulet}.md`
