# Claude Skills - Security and Permissions

**Last Updated:** October 19, 2025

---

## ◉ Overview

Claude Skills can restrict tool access using the `allowed-tools` field, implementing **principle of least privilege** for security-sensitive workflows.

---

## ◉ allowed-tools Field

### Syntax

```yaml
---
name: skill-name
description: Description
allowed-tools: Read Grep Glob
---
```

**Supported in:** Claude Code (as of October 2025)
**Not supported in:** Claude.ai, API (fields ignored but won't cause errors)

### Available Tools

| Tool | Purpose |
|------|---------|
| `Read` | Read files |
| `Write` | Create new files |
| `Edit` | Modify existing files |
| `Bash` | Execute shell commands |
| `Glob` | File pattern matching |
| `Grep` | Search file contents |

### Examples

**Read-only skill:**
```yaml
allowed-tools: Read Grep Glob
```

**Analysis skill:**
```yaml
allowed-tools: Read Bash
```

**Full access (default):**
```yaml
allowed-tools: Read Write Edit Bash Glob Grep
# Or omit field entirely
```

---

## ◉ Use Cases

### Security Audits

```yaml
---
name: security-auditor
description: Audit code for security issues without making changes
allowed-tools: Read Grep Glob
---

# Security Auditor

Read and analyze code for security vulnerabilities.

Cannot modify files - view only.
```

### Data Validation

```yaml
---
name: data-validator
description: Validate data files without modifications
allowed-tools: Read Bash
---

# Data Validator

Validate CSV/JSON data using validation scripts.

Can read files and run validation scripts.
Cannot write or edit files.
```

### Safe Exploration

```yaml
---
name: code-explorer
description: Explore codebase structure safely
allowed-tools: Read Glob Grep
---

# Code Explorer

Browse and search codebase.

Search-only access, no modifications possible.
```

---

## ◉ Claude Code Permissions

### Global Configuration

**File:** `~/.claude/config.json` or `~/.claude.json`

```json
{
  "permissions": {
    "allow": [
      "cat",
      "ls",
      "grep"
    ],
    "ask": [
      "git",
      "npm",
      "python"
    ],
    "deny": [
      "rm -rf",
      "sudo",
      "curl"
    ]
  }
}
```

### Permission Types

**Allowlist (`permissions.allow`):**
- Commands that run without prompting
- Use for 100% safe commands only
- Example: `ls`, `cat`, `grep`

**Asklist (`permissions.ask`):**
- Commands that prompt for confirmation
- Use for potentially risky commands
- Example: `git`, `npm install`, `python script.py`

**Denylist (`permissions.deny`):**
- Commands that are blocked entirely
- Use for dangerous operations
- Example: `rm -rf`, `sudo`, `chmod 777`

### CLI Flags

```bash
# Allow specific tools
claude --allowedTools Read,Bash,Grep

# Disallow specific tools
claude --disallowedTools Write,Edit

# Permission mode
claude --permission-mode ask    # Prompt for all tools
claude --permission-mode accept # Auto-accept (dangerous!)
claude --permission-mode deny   # Deny all tools
```

---

## ◉ Security Best Practices

### Principle of Least Privilege

**Grant minimum necessary permissions:**

```yaml
# ✗ Too permissive for analysis task
allowed-tools: Read Write Edit Bash Glob Grep

# ✓ Minimal permissions
allowed-tools: Read Grep Glob
```

### Sandbox Untrusted Skills

```yaml
---
name: experimental-skill
description: Experimental untested skill
allowed-tools: Read    # Severely restricted
---
```

### Audit Skill Content

Before installing third-party skills:

1. **Review SKILL.md** - Check instructions for suspicious content
2. **Inspect scripts** - Review all code in `scripts/`
3. **Check resources** - Verify resource files are legitimate
4. **Test in isolation** - Run in dedicated test environment first

### Trust Sources

**Trusted:**
- ✓ anthropics/skills (official)
- ✓ Your organization's skills
- ✓ Well-reviewed community skills

**Untrusted:**
- ⚠ Random GitHub repositories
- ⚠ Skills without documentation
- ⚠ Skills from unknown authors

---

## ◉ Code Execution Security

### Isolated Containers

Skills with scripts run in **isolated sandbox environments:**

```
┌─────────────────────────────┐
│ Code Execution Container    │
│ - No network access*        │
│ - Limited filesystem access │
│ - Resource limits (CPU/RAM) │
│ - Temporary storage only    │
└─────────────────────────────┘

*Network restrictions vary by platform
```

### Script Security

**DO:**
```python
# ✓ Validate inputs
def process(data):
    if not isinstance(data, str):
        raise TypeError("Expected string")
    # Process data

# ✓ Use safe operations
import json
data = json.loads(safe_input)

# ✓ Handle errors
try:
    result = risky_operation()
except Exception as e:
    logging.error(f"Error: {e}")
    sys.exit(1)
```

**DON'T:**
```python
# ✗ Execute arbitrary code
eval(user_input)
exec(user_code)

# ✗ Unsafe file operations
os.system(f"rm -rf {user_path}")

# ✗ Expose secrets
password = "hardcoded_secret"
```

### Resource Files

**Validate resource content:**

```markdown
## Brand Logo

Logo file: `resources/logo.svg`

Verified: SHA256: abc123...
```

---

## ◉ Data Privacy

### Avoid Sensitive Data

```yaml
# ✗ Don't include
---
name: api-client
description: Call API
metadata:
  api_key: "sk-1234567890"    # NEVER!
  database_password: "secret"  # NEVER!
---

# ✓ Use environment variables
---
name: api-client
description: Call API with credentials from environment
---

## Configuration

Set environment variables:
- `API_KEY`: Your API key
- `DB_PASSWORD`: Database password
```

### Secure Credential Handling

```bash
# In scripts
#!/usr/bin/env python3
import os

api_key = os.environ.get('API_KEY')
if not api_key:
    print("Error: API_KEY not set", file=sys.stderr)
    sys.exit(1)

# Use api_key securely
```

---

## ◉ Compliance

### Industry-Specific

**Healthcare (HIPAA):**
```yaml
---
name: patient-data-analyzer
description: Analyze patient data with HIPAA compliance
allowed-tools: Read    # Read-only for audit trail
metadata:
  compliance: HIPAA
  audit_logging: enabled
---
```

**Finance (SOX, PCI):**
```yaml
---
name: financial-validator
description: Validate financial data for SOX compliance
allowed-tools: Read Bash
metadata:
  compliance: SOX
  data_classification: confidential
---
```

**Enterprise:**
```yaml
---
name: code-reviewer
description: Review code for security and compliance
allowed-tools: Read Grep Glob
metadata:
  security_level: high
  approved_by: security-team
---
```

---

## ◉ Monitoring and Auditing

### Logging

```python
# In scripts
import logging

logging.basicConfig(
    filename='skill-audit.log',
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(message)s'
)

logging.info(f"Skill {skill_name} executed")
logging.info(f"User: {user_id}")
logging.info(f"Action: {action}")
```

### Usage Tracking

```yaml
---
name: sensitive-skill
description: Handle sensitive operations
metadata:
  audit_required: true
  log_all_usage: true
  notify_security_team: true
---
```

---

## ◉ Security Checklist

### Before Installing Skill

- [ ] Source is trusted
- [ ] SKILL.md reviewed
- [ ] All scripts inspected
- [ ] No hardcoded secrets
- [ ] Appropriate allowed-tools set
- [ ] Resource files verified
- [ ] Tested in isolation
- [ ] Documentation reviewed

### Before Deploying to Team

- [ ] Security team approved
- [ ] Compliance requirements met
- [ ] Audit logging configured
- [ ] Access controls set
- [ ] Incident response plan
- [ ] User training completed
- [ ] Monitoring enabled

---

## ◉ Incident Response

### If Compromised Skill Detected

1. **Immediate Actions:**
```bash
# Remove skill
rm -rf ~/.claude/skills/compromised-skill

# Restart Claude Code
# Verify skill no longer loaded
```

2. **Investigation:**
- Review skill content
- Check audit logs
- Identify impact
- Document findings

3. **Remediation:**
- Remove from all systems
- Notify team
- Update security policies
- Add to blocklist

---

## ◉ Summary

**Key Points:**

- Use `allowed-tools` to restrict capabilities
- Apply principle of least privilege
- Audit third-party skills before installing
- Never hardcode sensitive data
- Use environment variables for secrets
- Monitor and log skill usage
- Have incident response plan

**Permission Levels:**

| Level | Tools | Use Case |
|-------|-------|----------|
| **Read-only** | Read, Grep, Glob | Audits, analysis |
| **Read + Execute** | Read, Bash | Validation, reporting |
| **Limited Write** | Read, Write, Bash | Safe automation |
| **Full Access** | All tools | Trusted operations |

---

**Navigation:**
- [← Back to Best Practices](06-Best-Practices.md)
- [Next: Example Skills Catalog →](08-Example-Skills-Catalog.md)

#fin
