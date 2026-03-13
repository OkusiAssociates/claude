---
name: audit-python
description: Python 3.12+ Raw Code Audit
---

Perform a comprehensive Python 3.12+ raw code audit of this codebase using the **audit-python** skill methodology.

Run all phases in order:

0. **Project Discovery** — read config files, understand project conventions
1. **Automated Tooling** — run `ruff check .`, `ruff format --check .`, `mypy`
2. **Security Review** — path traversal, injection, dangerous functions, secrets
3. **Architecture & Design** — module organization, class design, error handling
4. **Performance** — algorithmic issues, Python-specific patterns, I/O
5. **Testing Quality** — coverage gaps, edge cases, anti-patterns
6. **Dependency Audit** — non-stdlib imports, justification, alternatives

Focus on what automated tools miss. Do not manually re-audit style issues that ruff already catches.

Save the complete report to `./AUDIT-PYTHON.md`.
