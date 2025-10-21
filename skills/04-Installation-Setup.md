# Claude Skills - Installation and Setup

**Last Updated:** October 19, 2025

---

## Table of Contents

1. [Installation Locations](#installation-locations)
2. [Personal vs Project Skills](#personal-vs-project-skills)
3. [Installation Methods](#installation-methods)
4. [Plugin Marketplace](#plugin-marketplace)
5. [Directory Structure](#directory-structure)
6. [Configuration](#configuration)
7. [Verification and Testing](#verification-and-testing)

---

## ◉ Installation Locations

### Claude Code

**Personal Skills** (User-specific, available across all projects):
```
~/.claude/skills/
```

**Project Skills** (Shared with team, git-tracked):
```
{project-root}/.claude/skills/
```

**Plugin Skills** (Installed via marketplace):
```
~/.claude/plugins/{plugin-name}/skills/
```

### Claude.ai

**Cloud Storage:**
- Skills uploaded via web interface
- Stored in Anthropic cloud
- Personal: Available to your account only
- Team: Shared with organization (Team/Enterprise plans)

### API

**Managed Programmatically:**
- Upload via `/skills` API endpoint
- Reference by `skill_id` in requests
- Version control supported

---

## ◉ Personal vs Project Skills

### Personal Skills (`~/.claude/skills/`)

**Characteristics:**
- Stored in user home directory
- Available across ALL projects
- Not shared with team
- Not in version control
- Persist across project changes

**Use Cases:**
- Personal productivity workflows
- Individual coding preferences
- Private templates and tools
- Experimental skills

**Installation:**
```bash
mkdir -p ~/.claude/skills/my-skill
vim ~/.claude/skills/my-skill/SKILL.md
```

**Example:**
```bash
~/.claude/skills/
├── email-signature/
│   └── SKILL.md
├── code-style-preferences/
│   └── SKILL.md
└── quick-notes/
    └── SKILL.md
```

### Project Skills (`.claude/skills/`)

**Characteristics:**
- Stored in project directory
- Checked into git
- Shared with entire team
- Project-specific
- Version controlled alongside code

**Use Cases:**
- Team coding standards
- Project-specific workflows
- Shared templates
- Organization guidelines

**Installation:**
```bash
cd /path/to/project
mkdir -p .claude/skills/project-standard
vim .claude/skills/project-standard/SKILL.md
git add .claude/skills/
git commit -m "Add project skill"
```

**Example:**
```bash
/my-project/
├── .claude/
│   └── skills/
│       ├── coding-standard/
│       │   └── SKILL.md
│       ├── api-guidelines/
│       │   └── SKILL.md
│       └── test-requirements/
│           └── SKILL.md
├── src/
└── tests/
```

### Skill Priority

When skills with same name exist in multiple locations:
1. Project skills (`.claude/skills/`) - Highest priority
2. Personal skills (`~/.claude/skills/`)
3. Plugin skills (`~/.claude/plugins/`)

---

## ◉ Installation Methods

### Method 1: Manual Creation

**Steps:**

1. Create skill directory:
```bash
mkdir -p ~/.claude/skills/my-new-skill
```

2. Create SKILL.md:
```bash
cat > ~/.claude/skills/my-new-skill/SKILL.md <<'EOF'
---
name: my-new-skill
description: Description of what this skill does and when to use it
---

# My New Skill

## Instructions

[Your instructions here]
EOF
```

3. Add resources (optional):
```bash
mkdir -p ~/.claude/skills/my-new-skill/resources
cp template.docx ~/.claude/skills/my-new-skill/resources/
```

4. Restart Claude Code:
```bash
# Skills loaded at startup
# Restart to pick up new skill
```

### Method 2: Clone from Repository

```bash
# Clone anthropics/skills examples
cd ~/.claude/skills/
git clone https://github.com/anthropics/skills.git temp
cp -r temp/algorithmic-art ./
cp -r temp/brand-guidelines ./
rm -rf temp
```

### Method 3: Plugin Marketplace

```bash
# Add marketplace
/plugin marketplace add anthropics/skills

# Browse available skills
/plugin list

# Install specific skill
/plugin install @anthropics/skills/powerpoint
```

### Method 4: API Upload (For API Users)

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

# Upload skill
with open("SKILL.md") as f:
    skill_content = f.read()

response = client.skills.create(
    name="my-skill",
    content=skill_content
)

skill_id = response.id
print(f"Skill uploaded: {skill_id}")
```

---

## ◉ Plugin Marketplace

### Adding Marketplaces

**Official Anthropic Marketplace:**
```bash
/plugin marketplace add anthropics/skills
```

**Third-Party Marketplaces:**
```bash
/plugin marketplace add org-name/marketplace-repo
```

**Local Marketplace:**
```bash
/plugin marketplace add ./local-marketplace-dir
```

### Browsing Skills

```bash
# List all plugins/skills in marketplaces
/plugin list

# Search for specific skill
/plugin search powerpoint
```

### Installing from Marketplace

**Syntax:**
```bash
/plugin install @marketplace/skill-name
```

**Examples:**
```bash
/plugin install @anthropics/skills/powerpoint
/plugin install @anthropics/skills/excel-advanced
/plugin install @community/financial-modeling
```

### Updating Skills

```bash
# Update specific skill
/plugin update @anthropics/skills/powerpoint

# Update all from marketplace
/plugin update --all
```

### Removing Skills

```bash
/plugin uninstall @anthropics/skills/powerpoint
```

### Alternative CLI Tool

**NPM-based installer:**
```bash
# Install via npx
npx claude-plugins install @anthropics/skills/powerpoint

# Direct installation without marketplace setup
npx claude-plugins install github:user/repo/skill-name
```

---

## ◉ Directory Structure

### Recommended Structure

```
~/.claude/skills/
├── brand-guidelines/
│   ├── SKILL.md
│   ├── resources/
│   │   ├── logos/
│   │   │   ├── logo-full.svg
│   │   │   └── logo-icon.svg
│   │   ├── templates/
│   │   │   ├── presentation.pptx
│   │   │   └── document.docx
│   │   └── examples/
│   │       └── branded-example.pdf
│   └── scripts/
│       └── validate_branding.py
│
├── code-reviewer/
│   ├── SKILL.md
│   ├── resources/
│   │   └── checklist.md
│   └── scripts/
│       ├── check_style.py
│       └── run_linter.sh
│
└── data-validator/
    ├── SKILL.md
    ├── resources/
    │   ├── schemas/
    │   │   └── data-schema.json
    │   └── examples/
    │       ├── valid.csv
    │       └── invalid.csv
    └── scripts/
        ├── validate.py
        └── requirements.txt
```

### File Organization Best Practices

**1. Keep SKILL.md at Root:**
```
✓ skill-name/SKILL.md
✗ skill-name/docs/SKILL.md
```

**2. Group Related Resources:**
```
resources/
├── templates/    # Template files
├── examples/     # Example inputs/outputs
├── reference/    # Documentation, guides
└── data/         # Configuration, constants
```

**3. Organize Scripts by Function:**
```
scripts/
├── validation/   # Validation scripts
├── processing/   # Data processing
├── reporting/    # Report generation
└── utils/        # Utility functions
```

**4. Include Documentation:**
```
skill-name/
├── SKILL.md         # Main skill definition
├── README.md        # Usage instructions
├── CHANGELOG.md     # Version history
└── LICENSE          # License terms
```

---

## ◉ Configuration

### Global Configuration

**File:** `~/.claude/config.json`

```json
{
  "skills": {
    "enabled": true,
    "autoload": true,
    "locations": [
      "~/.claude/skills",
      ".claude/skills"
    ],
    "maxConcurrentSkills": 8,
    "preferProjectSkills": true
  }
}
```

### Project Configuration

**File:** `.claude/config.json`

```json
{
  "skills": {
    "enabled": ["coding-standard", "api-guidelines"],
    "disabled": ["experimental-feature"],
    "strictMode": true
  }
}
```

### Skill-Specific Configuration

**In SKILL.md metadata:**
```yaml
---
name: my-skill
description: Skill description
metadata:
  autoload: true
  priority: high
  tags: ["development", "quality"]
---
```

---

## ◉ Verification and Testing

### Verify Installation

**Check skill directory:**
```bash
ls -la ~/.claude/skills/my-skill/
# Should show SKILL.md at minimum
```

**Validate SKILL.md format:**
```bash
# Check YAML frontmatter
head -n 10 ~/.claude/skills/my-skill/SKILL.md

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('~/.claude/skills/my-skill/SKILL.md'))"
```

**List loaded skills:**
```bash
# In Claude Code
/skills list

# Or check startup log
claude --verbose
```

### Test Skill Activation

**Method 1: Direct Mention**
```
In Claude Code:
"Use the my-skill skill to process this data"
```

**Method 2: Trigger Words**
```
In Claude Code:
"Create a branded presentation"  # Should activate brand-guidelines
```

**Method 3: Explicit Check**
```
In Claude Code:
"What skills do you have loaded?"
"Is the my-skill skill available?"
```

### Debugging

**Skill not loading:**
```bash
# Check file exists
stat ~/.claude/skills/my-skill/SKILL.md

# Check YAML is valid
python3 <<EOF
import yaml
with open('~/.claude/skills/my-skill/SKILL.md') as f:
    content = f.read()
    parts = content.split('---', 2)
    metadata = yaml.safe_load(parts[1])
    print(f"Name: {metadata.get('name')}")
    print(f"Description: {metadata.get('description')}")
EOF

# Check permissions
ls -l ~/.claude/skills/my-skill/SKILL.md
# Should be readable
```

**Skill not activating:**
```bash
# Test description matching
# Make sure description includes relevant trigger words

# Try explicit mention
# "Use [skill-name] to..."
```

### Example Test Script

```bash
#!/bin/bash
# test-skill-installation.sh

SKILL_DIR="$HOME/.claude/skills/my-skill"

echo "Testing skill installation..."

# Check directory
if [[ ! -d "$SKILL_DIR" ]]; then
  echo "✗ Skill directory not found: $SKILL_DIR"
  exit 1
fi
echo "✓ Skill directory exists"

# Check SKILL.md
if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "✗ SKILL.md not found"
  exit 1
fi
echo "✓ SKILL.md exists"

# Validate YAML
if ! python3 -c "import yaml; yaml.safe_load(open('$SKILL_DIR/SKILL.md'))" 2>/dev/null; then
  echo "✗ Invalid YAML frontmatter"
  exit 1
fi
echo "✓ YAML frontmatter valid"

# Extract metadata
python3 <<EOF
import yaml
with open('$SKILL_DIR/SKILL.md') as f:
    content = f.read()
    parts = content.split('---', 2)
    if len(parts) >= 3:
        metadata = yaml.safe_load(parts[1])
        print(f"✓ Skill name: {metadata.get('name')}")
        print(f"✓ Description length: {len(metadata.get('description', ''))} chars")
    else:
        print("✗ Invalid frontmatter structure")
        exit(1)
EOF

echo "
✓ All checks passed!
Restart Claude Code to load the skill."
```

---

## ◉ Best Practices

### DO:

- ✓ Use clear, descriptive skill names
- ✓ Put team skills in `.claude/skills/` (git-tracked)
- ✓ Put personal skills in `~/.claude/skills/`
- ✓ Include README.md for complex skills
- ✓ Version your skills (in metadata)
- ✓ Test skills after installation
- ✓ Document resource files
- ✓ Keep skills focused and single-purpose

### DON'T:

- ✗ Mix personal and project skills
- ✗ Hard-code absolute paths
- ✗ Ignore YAML validation errors
- ✗ Commit personal skills to git
- ✗ Create overly complex mega-skills
- ✗ Forget to restart Claude Code after changes

---

**Navigation:**
- [← Back to Architecture](03-Architecture-Progressive-Disclosure.md)
- [Next: API Integration →](05-API-Integration.md)

#fin
