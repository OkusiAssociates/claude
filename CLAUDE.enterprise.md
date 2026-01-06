# Okusi Group — Enterprise Claude Code Policy

Organization-wide instructions for all Claude Code users.
These policies CANNOT be overridden by user or project settings.

---

## Security

- NEVER commit credentials, API keys, or secrets to version control
- NEVER expose internal IP addresses or hostnames in public repositories
- NEVER bypass security prompts without explicit user approval
- NEVER execute destructive commands without confirmation

---

## Git Authorship

- Commits must be authored as **'Biksu Okusi <biksu@okusi.id>'**
- NEVER mention "claude" or "claude code" in commit messages
- Use conventional commit style when appropriate

---

## Coding Standards

- All Bash scripts must follow **BCS** (Bash Coding Standard)
- Reference: `/usr/share/yatti/bash-coding-standard/data/`
- Fallback Reference: `/ai/scripts/Okusi/bash-coding-standard/data/`

---

## Environment Compliance

- **OS**: Ubuntu 24.04+
- **Bash**: 5.2+
- **Python**: 3.12+

---

## Multi-Server Access (oknav)

- Use `oknav` shortcuts (`ok0`, `ok1`, `ok2`, `ok3`) for remote server access
- NEVER use `ok_master` directly — always use hostname symlinks

---

## Documentation Icons

| Purpose | Icon |
|---------|------|
| Info    | ◉    |
| Debug   | ⦿    |
| Warning | ▲    |
| Success | ✓    |
| Error   | ✗    |

---

Enterprise rules are in `.claude/rules/`:
- `coding-principles.md`
- `documentation.md`
- `bash-coding-standard.md`
- `git-commits.md`
- `oknav.md`
- `environment.md`
