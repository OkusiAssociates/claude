# Bash Coding Standard (BCS)

All Bash scripts must adhere to the BCS standard. BCS defines 101 rules across **12 sections** covering script structure, variables, strings/quoting, functions, control flow, error handling, I/O, command-line, file operations, security, concurrency, and style/development.

## Compliance Checking

Use `bcscheck <script>` to verify compliance against the standard. Takes up to 10 minutes per script (uses LLM backend).

## BCS Location (FHS-Compliant Search Order)

1. Script directory (development mode)
2. `/usr/local/share/yatti/BCS/data/` (local install)
3. `/usr/share/yatti/BCS/data/` (system install)
4. `/ai/scripts/Okusi/BCS/data/` (fallback)
