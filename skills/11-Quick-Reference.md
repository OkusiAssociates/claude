# Claude Skills - Quick Reference

**Last Updated:** October 19, 2025

---

## ◉ SKILL.md Template

### Minimal Template

```markdown
---
name: skill-name
description: What this skill does and when to use it; include trigger words
---

# Skill Name

Brief overview.

## Instructions

1. Step one
2. Step two
3. Step three

## Examples

**Input:** Example request
**Output:** Expected result
```

### Complete Template

```markdown
---
name: skill-name
description: Complete description with triggers and context; mention specific use cases
license: MIT
allowed-tools: Read Write Bash
metadata:
  version: "1.0.0"
  author: "Your Name"
  category: "category-name"
---

# Skill Name

Detailed overview of skill purpose and capabilities.

## Purpose

What problem this skill solves.

## Instructions

Step-by-step guidance:

1. First action
2. Second action
3. Final action

## Guidelines

- Rule 1
- Rule 2
- Rule 3

## Examples

### Example 1: Basic Usage

**Input:**
```
User request
```

**Output:**
```
Expected result
```

### Example 2: Advanced Usage

**Input:**
```
Complex request
```

**Output:**
```
Detailed result
```

## Resources

- `resources/template.md` - Description
- `scripts/process.py` - Description

## Notes

Additional context or special cases.
```

---

## ◉ Installation Commands

### Manual Installation

```bash
# Create personal skill
mkdir -p ~/.claude/skills/skill-name
vim ~/.claude/skills/skill-name/SKILL.md

# Create project skill
mkdir -p .claude/skills/skill-name
vim .claude/skills/skill-name/SKILL.md
```

### Plugin Marketplace

```bash
# Add marketplace
/plugin marketplace add anthropics/skills

# Install skill
/plugin install @anthropics/skills/skill-name

# List available
/plugin list

# Update skill
/plugin update @anthropics/skills/skill-name
```

### Clone from GitHub

```bash
cd ~/.claude/skills/
git clone https://github.com/anthropics/skills temp
cp -r temp/skill-name ./
rm -rf temp
```

---

## ◉ API Usage

### Basic Skill Usage

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    tools=[{"type": "code_execution"}],
    container={
        "skills": [
            {"type": "skill", "skill_id": "powerpoint", "version": "1.0"}
        ]
    },
    messages=[
        {"role": "user", "content": "Create presentation"}
    ]
)
```

### Multiple Skills

```python
container={
    "skills": [
        {"type": "skill", "skill_id": "brand-guidelines"},
        {"type": "skill", "skill_id": "powerpoint"},
        {"type": "skill", "skill_id": "financial-reporting"}
    ]
}
# Maximum 8 skills per request
```

---

## ◉ Validation Commands

### YAML Validation

```bash
# Python
python3 -c "import yaml; print(yaml.safe_load(open('SKILL.md')))"

# Extract frontmatter
sed -n '/^---$/,/^---$/p' SKILL.md

# Validate online
# yamllint.com
```

### Skill Verification

```bash
# Check exists
ls -la ~/.claude/skills/skill-name/SKILL.md

# Verify name matches
python3 <<EOF
import yaml
with open('~/.claude/skills/skill-name/SKILL.md') as f:
    content = f.read()
    metadata = yaml.safe_load(content.split('---')[1])
    print(f"Name: {metadata['name']}")
    print(f"Description length: {len(metadata['description'])}")
EOF
```

---

## ◉ Common Patterns

### Style Guide Skill

```yaml
---
name: code-style
description: Enforce coding standards; use for code review
allowed-tools: Read
---

# Code Style Guide

## Rules
- Indentation: 2 spaces
- Line length: 80 chars
- Naming: snake_case

## Checklist
- [ ] Proper indentation
- [ ] No long lines
- [ ] Consistent naming
```

### Template Generator

```yaml
---
name: email-templates
description: Generate business emails; use for professional correspondence
---

# Email Templates

## Format
```
Subject: [Topic]

Dear [Name],

[Body]

Best regards,
[Signature]
```

## Templates
- Meeting: `resources/meeting.md`
- Status: `resources/status.md`
```

### Validation Skill

```yaml
---
name: data-validator
description: Validate CSV data; use before importing data
allowed-tools: Read Bash
---

# Data Validator

## Usage
```bash
python scripts/validate.py data.csv
```

## Rules
- Email: Valid format
- Date: ISO 8601
- Age: 18-120
```

---

## ◉ Directory Structure

```
skill-name/
├── SKILL.md              # Required: Main definition
├── README.md             # Optional: Documentation
├── resources/            # Optional: Supporting files
│   ├── templates/
│   ├── examples/
│   └── reference/
└── scripts/              # Optional: Executable code
    ├── validate.py
    └── process.sh
```

---

## ◉ Frontmatter Fields

### Required

```yaml
name: skill-name          # Matches directory name
description: Description  # Max 1024 chars, includes triggers
```

### Optional

```yaml
license: MIT                    # License terms
allowed-tools: Read Bash        # Tool restrictions
metadata:                       # Extensible metadata
  version: "1.0.0"
  author: "Name"
  category: "category"
```

---

## ◉ Trigger Words Best Practices

### Good Triggers

```yaml
description: Create PowerPoint presentations; use when user mentions slides, presentations, pitch decks, or PowerPoint
```

**Triggers:** PowerPoint, presentations, slides, pitch decks

### Poor Triggers

```yaml
description: Helps with presentations
```

**Triggers:** presentations (too vague)

---

## ◉ Token Optimization

### Use Tables

```markdown
# ✗ Verbose (200 tokens)
The primary color is #FF5733...

# ✓ Concise (50 tokens)
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #FF5733 | Headers |
```

### Reference Resources

```markdown
# ✗ Embedded (5000 tokens)
[Large content inline]

# ✓ Referenced (100 tokens)
See `resources/guide.md` for details.

Key points:
- Point 1
- Point 2
```

### Use Scripts

```markdown
# ✗ Algorithm described (500 tokens)
To validate: [steps...]

# ✓ Script reference (30 tokens)
Run: `python scripts/validate.py`
```

---

## ◉ Troubleshooting

### Skill Not Loading

```bash
# Check location
ls ~/.claude/skills/skill-name/SKILL.md

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('~/.claude/skills/skill-name/SKILL.md'))"

# Restart Claude Code
# Skills load at startup
```

### Skill Not Activating

```
# Try explicit mention
"Use the skill-name skill to..."

# Improve description triggers
Add specific keywords users might mention
```

### YAML Errors

```yaml
# ✗ Missing quotes
description: Error: breaks

# ✓ Quoted
description: "Error: works"

# ✗ Tab characters
→name: skill

# ✓ Spaces
  name: skill
```

---

## ◉ File Paths

```markdown
# ✓ Relative paths
resources/template.docx
scripts/validate.py

# ✗ Absolute paths
/home/user/resources/template.docx
```

---

## ◉ Testing Checklist

- [ ] SKILL.md exists at skill root
- [ ] YAML frontmatter valid
- [ ] `name` matches directory
- [ ] `description` under 1024 chars
- [ ] Description includes triggers
- [ ] Resources referenced correctly
- [ ] Scripts executable
- [ ] Tested activation
- [ ] Claude Code restarted

---

## ◉ Useful Links

- **Docs:** https://docs.claude.com/en/docs/claude-code/skills
- **GitHub:** https://github.com/anthropics/skills
- **Announcement:** https://www.anthropic.com/news/skills
- **API Guide:** https://docs.claude.com/en/api/skills-guide

---

**Navigation:**
- [← Back to Limitations](10-Limitations-Constraints.md)
- [Return to README](00-README.md)

#fin
