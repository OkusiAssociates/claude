# Claude Skills - Best Practices

**Last Updated:** October 19, 2025

---

## ◉ Description Writing

### Write in Third Person

```yaml
# ✗ Wrong (first person)
description: I help create presentations

# ✓ Correct (third person)
description: Creates presentations following brand guidelines
```

### Include Specific Triggers

```yaml
# ✗ Vague
description: Helps with documents

# ✓ Specific with triggers
description: Generate Excel financial reports with formulas and charts; use when user requests spreadsheets, budgets, forecasts, or financial analysis
```

### Mention Context

```yaml
# ✓ Good - includes what, when, and key details
description: Apply Okusi Group brand standards to communications including colors (#FF8C00, #001f3f) and fonts (Montserrat, Open Sans); use when creating branded content, marketing materials, or external-facing documents
```

---

## ◉ Development Process

### Use Claude to Create Skills

1. **Work with Claude ("Claude A")** to design the skill
2. **Test with another Claude instance ("Claude B")**
3. Iterate based on results

**Example workflow:**

```
You (to Claude A): "Help me create a skill for Python code reviews"

Claude A: [Designs SKILL.md with best practices]

You: [Save skill, test with Claude B]

You (to Claude B): "Review this Python code"

Claude B: [Uses the skill]

You (to Claude A): "The skill missed X, let's improve it"

Claude A: [Refines skill]

[Repeat until skill works well]
```

### Start Simple, Add Complexity

```markdown
# Version 1.0 - Basic
---
name: email-validator
description: Validate email addresses
---

## Instructions
Check if email contains @ and .

# Version 2.0 - Enhanced
[Add regex patterns, domain validation]

# Version 3.0 - Advanced
[Add scripts, MX record checking, disposable email detection]
```

### Test Incrementally

```bash
# Test after each change
1. Make small change to SKILL.md
2. Restart Claude Code
3. Test the specific change
4. Verify it works as expected
5. Move to next change
```

---

## ◉ Content Organization

### Use Tables for Efficiency

```markdown
# ✗ Verbose (150 tokens)
The primary color is orange with hex #FF8C00 used for headers.
The secondary color is navy with hex #001f3f used for body text.

# ✓ Efficient (40 tokens)
| Color | Hex | Usage |
|-------|-----|-------|
| Orange | #FF8C00 | Headers |
| Navy | #001f3f | Body text |
```

### Progressive Detail

```markdown
## Brand Colors

### Quick Reference (Tier 2)
- Primary: #FF8C00
- Secondary: #001f3f

### Complete Guide (Tier 3)
See `resources/brand-colors-complete.md` for:
- Color psychology
- Accessibility guidelines
- Print vs digital specifications
- Color combinations
```

### Include Examples

```markdown
## Email Format

**Good Example:**
```
Subject: Q3 Status Update

Dear Team,

I'm pleased to report...

Best regards,
John
```

**Bad Example:**
```
Subject: update

hey team heres the update...

john
```
```

---

## ◉ Token Optimization

### Keep Instructions Under 5,000 Tokens

**Target:** 1,000-3,000 tokens for Tier 2

**Strategies:**

1. **Reference instead of embed:**
```markdown
# ✗ Embedded
[5000 lines of content]

# ✓ Referenced
See `resources/complete-guide.md`

Key points:
- Point 1
- Point 2
```

2. **Use scripts for algorithms:**
```markdown
# ✗ Describe algorithm
To validate:
1. Check format
2. Verify domain
[detailed steps]

# ✓ Use script
Run: `python scripts/validate.py`
```

3. **Concise writing:**
```markdown
# ✗ Verbose
It is very important that you always remember to...

# ✓ Concise
Always...
```

---

## ◉ Resource Management

### Organize by Purpose

```
resources/
├── templates/     # Reusable templates
├── examples/      # Sample inputs/outputs
├── reference/     # Documentation
└── data/          # Configuration, constants
```

### Reference Clearly

```markdown
## Templates

Available templates:
- Presentation: `resources/templates/presentation.pptx`
- Report: `resources/templates/report.docx`
- Email: `resources/templates/email.html`

Use template when creating new documents.
```

### Keep Resources Focused

```
# ✓ Good - single purpose files
resources/brand-colors.md
resources/brand-fonts.md
resources/brand-logos.md

# ✗ Bad - monolithic files
resources/everything-about-brand.md
```

---

## ◉ Script Development

### Make Scripts Reusable

```python
#!/usr/bin/env python3
"""Reusable email validator."""

def validate_email(email):
    """Validate single email."""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

if __name__ == '__main__':
    import sys
    email = sys.argv[1]
    if validate_email(email):
        print(f"✓ Valid: {email}")
        sys.exit(0)
    else:
        print(f"✗ Invalid: {email}", file=sys.stderr)
        sys.exit(1)
```

### Document Script Usage

```markdown
## Email Validation

Run validation script:

```bash
python scripts/validate_email.py user@example.com
```

**Exit Codes:**
- `0`: Valid email
- `1`: Invalid email

**Output:**
- Stdout: Success message
- Stderr: Error message
```

### Include Requirements

```
scripts/
├── validate.py
├── process.py
└── requirements.txt    # Python dependencies
```

---

## ◉ Testing and Validation

### Test Across Models

```bash
# Test with different models
claude --model claude-3-5-sonnet-20241022 "Test request"
claude --model claude-3-opus-20240229 "Test request"
```

### Create Test Cases

```markdown
## Test Cases

### Test 1: Basic Usage
**Input:** "Create simple email"
**Expected:** Professional email following template

### Test 2: Complex Case
**Input:** "Create executive announcement email"
**Expected:** Formal email with appropriate tone

### Test 3: Edge Case
**Input:** "Create email with attachments"
**Expected:** Email mentioning attachments
```

### Version Control

```yaml
---
name: my-skill
description: Skill description
metadata:
  version: "1.2.0"
  changelog: |
    1.2.0: Added attachment support
    1.1.0: Improved tone guidelines
    1.0.0: Initial release
---
```

---

## ◉ Documentation

### Include README

```markdown
# Skill Name

## Overview
What this skill does

## Installation
```bash
cp -r skill-name ~/.claude/skills/
```

## Usage
How to trigger the skill

## Examples
Sample inputs and outputs

## Testing
How to verify it works

## Changelog
Version history
```

### Comment Complex Instructions

```markdown
## Validation Process

1. **Format Check** - Verify basic structure
   <!-- Must happen first to avoid processing invalid data -->

2. **Business Rules** - Apply domain logic
   <!-- See resources/rules.md for complete rule set -->

3. **Report Generation** - Create validation report
   <!-- Format specified in resources/report-template.md -->
```

---

## ◉ Security

### Use allowed-tools

```yaml
---
name: safe-reader
description: Read and analyze files without modifications
allowed-tools: Read Grep Glob
---
```

### Validate Inputs

```markdown
## Input Validation

Before processing:
1. Verify file exists
2. Check file size (< 10MB)
3. Validate file type
4. Sanitize user input

Use: `python scripts/validate_input.py`
```

### Avoid Sensitive Data

```markdown
# ✗ Don't include
api_key: "sk-1234567890"
password: "secret123"

# ✓ Reference securely
API key: Use environment variable $API_KEY
Password: Prompt user securely
```

---

## ◉ Maintenance

### Regular Reviews

```bash
# Quarterly review checklist
- [ ] Test skill still works
- [ ] Update dependencies
- [ ] Review documentation
- [ ] Check for improvements
- [ ] Update version number
```

### Gather Feedback

```markdown
## Feedback

Please report issues:
- Email: support@example.com
- GitHub: github.com/user/skill/issues
- Slack: #skills-feedback
```

### Monitor Usage

```python
# Log skill usage
import logging

logging.info(f"Skill {skill_name} used for {task}")
```

---

## ◉ Summary Checklist

### Before Publishing

- [ ] YAML frontmatter valid
- [ ] Description includes triggers
- [ ] Instructions clear and concise
- [ ] Examples provided
- [ ] Resources organized
- [ ] Scripts tested
- [ ] Documentation complete
- [ ] Version number set
- [ ] License specified
- [ ] Tested across models
- [ ] Token count optimized
- [ ] Security reviewed

---

**Navigation:**
- [← Back to API Integration](05-API-Integration.md)
- [Next: Security & Permissions →](07-Security-Permissions.md)

#fin
