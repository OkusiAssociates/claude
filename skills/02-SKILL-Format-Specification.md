# SKILL.md Format Specification

**Last Updated:** October 19, 2025
**Specification Version:** 1.0 (Feature Preview)

---

## Table of Contents

1. [File Structure Overview](#file-structure-overview)
2. [YAML Frontmatter](#yaml-frontmatter)
3. [Markdown Content](#markdown-content)
4. [Supporting Files](#supporting-files)
5. [Validation and Testing](#validation-and-testing)
6. [Complete Examples](#complete-examples)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

---

## ◉ File Structure Overview

Every Claude Skill is a **directory** containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md              # Required: Main skill definition
├── resources/            # Optional: Supporting files
│   ├── template.docx
│   ├── examples/
│   └── reference.md
└── scripts/              # Optional: Executable code
    ├── validate.py
    └── process.sh
```

### File Naming Requirements

**Directory Name:**
- Use hyphen-case (kebab-case): `my-skill-name`
- No spaces or special characters
- Must match the `name` field in YAML frontmatter
- Examples: `brand-guidelines`, `excel-advanced`, `report-generator`

**SKILL.md:**
- Must be named exactly `SKILL.md` (case-sensitive)
- Must be at root of skill directory
- Must use UTF-8 encoding

---

## ◉ YAML Frontmatter

The YAML frontmatter contains metadata that Claude uses for skill discovery and loading.

### Basic Structure

```yaml
---
name: skill-name
description: Complete description of what this skill does and when to use it
---
```

The frontmatter:
- **Must** start and end with `---` (exactly three hyphens)
- **Must** be at the very beginning of the file (no blank lines before)
- **Must** use valid YAML syntax
- **Must** contain required fields: `name` and `description`

### Required Fields

#### `name` (Required)

**Purpose:** Unique identifier for the skill

**Constraints:**
- Must match directory name
- Use hyphen-case format
- Maximum 64 characters
- No spaces, use hyphens instead
- Lowercase recommended
- Should be descriptive and memorable

**Examples:**
```yaml
name: brand-guidelines           # ✓ Good
name: advanced-excel-formulas    # ✓ Good
name: Brand Guidelines           # ✗ Bad: contains spaces
name: brand_guidelines           # ✗ Bad: use hyphens, not underscores
```

#### `description` (Required)

**Purpose:** Tells Claude when and why to use this skill

**Constraints:**
- Maximum 1,024 characters
- Must be clear and specific
- Should include triggers/contexts
- Written in third person
- Should describe both WHAT and WHEN

**Good Description Pattern:**
```yaml
description: Creates branded PowerPoint presentations following Company X guidelines; use when user requests slides, presentations, or pitch decks that need to follow brand standards including colors (#FF5733, #333333), fonts (Helvetica, Arial), and layout templates
```

**What Makes a Good Description:**
- ✓ Describes the capability ("Creates branded PowerPoint presentations")
- ✓ Specifies when to use ("when user requests slides, presentations, or pitch decks")
- ✓ Includes context ("that need to follow brand standards")
- ✓ Mentions key details ("colors, fonts, layout templates")

**Poor Description Examples:**
```yaml
# ✗ Too vague
description: Helps with PowerPoint

# ✗ First person (wrong POV)
description: I will help you create presentations

# ✗ Missing context
description: PowerPoint creator

# ✗ Too technical for discovery
description: Utilizes python-pptx library to generate OOXML presentation files
```

### Optional Fields

#### `license` (Optional)

**Purpose:** Specify licensing terms for the skill

**Format:** String

**Examples:**
```yaml
license: MIT
license: Apache-2.0
license: Proprietary - Internal Use Only
license: CC-BY-4.0
```

#### `allowed-tools` (Optional)

**Purpose:** Restrict Claude's tool access when this skill is active

**Format:** Space-separated list of tool names

**Supported in:** Claude Code only (as of October 2025)

**Available Tools:**
- `Read` - Read files
- `Write` - Create new files
- `Edit` - Modify existing files
- `Bash` - Execute shell commands
- `Glob` - File pattern matching
- `Grep` - Search file contents

**Examples:**
```yaml
# Read-only skill
allowed-tools: Read Grep Glob

# Read and analyze, but no writes
allowed-tools: Read Bash

# Full access (same as omitting the field)
allowed-tools: Read Write Edit Bash Glob Grep
```

**Use Cases:**
- Security-sensitive workflows
- Audit/analysis tasks that shouldn't modify data
- Compliance requirements
- Sandboxing untrusted skill content

#### `metadata` (Optional)

**Purpose:** Extensible key-value pairs for future use

**Format:** Dictionary/object

**Examples:**
```yaml
metadata:
  version: "1.2.0"
  author: "Gary Dean"
  organization: "Okusi Group"
  created: "2025-10-16"
  updated: "2025-10-19"
  category: "document-generation"
  tags: ["powerpoint", "branding", "presentations"]
```

**Current Status:** These fields are accepted but not actively used by Claude (as of October 2025). Include for documentation and future-proofing.

### Complete Frontmatter Example

```yaml
---
name: financial-report-generator
description: Generate standardized quarterly financial reports with balance sheets, income statements, and cash flow analysis; use when user requests financial reporting, accounting summaries, or CFO-level financial documents that need to follow GAAP standards and company-specific formatting
license: Proprietary - Internal Use Only
allowed-tools: Read Bash
metadata:
  version: "2.1.0"
  author: "Finance Team"
  organization: "Okusi Group"
  category: "finance"
  tags: ["reporting", "financial", "GAAP"]
  compliance: "SOX"
---
```

### YAML Syntax Rules

**Indentation:**
- Use 2 spaces (not tabs)
- Consistent indentation required

**Quoting:**
- Quote values containing special characters: `: , [ ] { } & * # ? | - < > = ! % @ \`
- Quote values with colons: `description: "Title: Subtitle format"`
- Single or double quotes both work

**Boolean Values:**
```yaml
active: true      # ✓ Correct
active: false     # ✓ Correct
active: True      # ✗ Not recommended (case-sensitive)
```

**Lists:**
```yaml
# Method 1: Inline
tags: ["finance", "reporting", "GAAP"]

# Method 2: Block style
tags:
  - finance
  - reporting
  - GAAP
```

**Objects/Dictionaries:**
```yaml
metadata:
  version: "1.0"
  author: "Name"
```

### Validation

**Online Validators:**
- [yamllint.com](http://www.yamllint.com/)
- [yaml-validator.com](https://yaml-validator.com/)

**Command Line:**
```bash
# Using Python
python3 -c "import yaml; yaml.safe_load(open('SKILL.md'))"

# Using Ruby
ruby -ryaml -e "YAML.load_file('SKILL.md')"

# Using yq
yq eval '.description' SKILL.md
```

**Common YAML Errors:**
```yaml
# ✗ Missing quotes around value with colon
description: Error: This will fail

# ✓ Correct
description: "Error: This will work"

# ✗ Inconsistent indentation
metadata:
  version: "1.0"
    author: "Name"    # Too much indent

# ✓ Correct
metadata:
  version: "1.0"
  author: "Name"

# ✗ Tab characters
→name: skill-name     # Tab used instead of spaces

# ✓ Correct
··name: skill-name    # Spaces used
```

---

## ◉ Markdown Content

The body of SKILL.md (after the frontmatter) contains the actual instructions Claude follows.

### Structure Recommendations

```markdown
---
name: my-skill
description: Description here
---

# Skill Name

Brief overview of what this skill does.

## Purpose

Detailed explanation of the skill's purpose and goals.

## Instructions

Step-by-step guidance for Claude to follow:

1. First, do X
2. Then, analyze Y
3. Finally, produce Z

## Guidelines

- Specific rules to follow
- Quality standards
- Formatting requirements

## Examples

### Example 1: Simple Case

**Input:**
```
User request example
```

**Output:**
```
Expected result
```

### Example 2: Complex Case

**Input:**
```
More complex request
```

**Output:**
```
Expected complex result
```

## Resources

Reference files available in this skill:
- `resources/template.docx` - Standard template
- `resources/style-guide.md` - Brand guidelines
- `scripts/validate.py` - Validation script

## Notes

Additional context, edge cases, or special considerations.
```

### Content Guidelines

**Be Specific and Actionable:**
```markdown
# ✗ Too vague
Create a good presentation.

# ✓ Specific and actionable
Create a presentation with:
1. Title slide with company logo (top-right, 100px height)
2. Section headers using Helvetica Bold 32pt in brand color #FF5733
3. Body text in Arial 16pt black (#333333)
4. Maximum 6 bullet points per slide
5. Slide numbers in bottom-right corner
```

**Include Context:**
```markdown
## Brand Colors

- Primary: #FF5733 (Coral Red) - Use for headers and key highlights
- Secondary: #333333 (Dark Gray) - Use for body text
- Accent: #FFC300 (Gold) - Use sparingly for callouts
- Background: #FFFFFF (White) - Use for all slide backgrounds

## When to Use Each Color

- Headers: Primary (#FF5733)
- Subheaders: Secondary (#333333)
- Body text: Secondary (#333333)
- Important callouts: Accent (#FFC300)
- Links: Primary (#FF5733) with underline
```

**Provide Examples:**
```markdown
## Email Signature Format

Standard format:
```
John Doe
Senior Consultant
Okusi Group

Email: john.doe@okusigroup.com
Phone: +62 361 123 4567
Web: okusigroup.com
```

Executive format:
```
John Doe, MBA
Chief Operating Officer
Okusi Group

john.doe@okusigroup.com | +62 361 123 4567
okusigroup.com | LinkedIn: /in/johndoe
```
```

### Markdown Features

**Headers:**
```markdown
# H1 - Main title
## H2 - Sections
### H3 - Subsections
#### H4 - Details
```

**Lists:**
```markdown
Ordered:
1. First step
2. Second step
3. Third step

Unordered:
- Item one
- Item two
  - Nested item
  - Another nested item
```

**Code Blocks:**
````markdown
Inline code: Use `variable_name` for references

Code block:
```python
def validate_email(email):
    return "@" in email and "." in email
```

Command:
```bash
python validate.py input.csv
```
````

**Links:**
```markdown
[Link text](https://example.com)
[Relative link to resource](resources/template.md)
```

**Tables:**
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |
```

**Emphasis:**
```markdown
*Italic text*
**Bold text**
***Bold and italic***
`Code formatting`
```

**Blockquotes:**
```markdown
> Important note or quote
> Continues on multiple lines
```

### Referencing Files

**Relative Paths:**
```markdown
## Templates

Use the presentation template located at:
- `resources/template.pptx`

For branding guidelines, see:
- `resources/brand/colors.md`
- `resources/brand/fonts.md`

## Scripts

Validation script:
- `scripts/validate_format.py`
```

**Loading Resources:**
```markdown
## When to Load Resources

Claude will automatically load these files when needed:

1. Brand guidelines (`resources/brand-guide.md`) - Loaded when creating branded content
2. Email templates (`resources/email-templates/`) - Loaded when composing emails
3. Code style guide (`resources/style-guide.md`) - Loaded when reviewing code
```

### Token Optimization

**Keep Instructions Under 5,000 Tokens:**

Rule of thumb: ~750 words ≈ 1,000 tokens

**Optimization Strategies:**

1. **Be Concise:**
```markdown
# ✗ Verbose (150 tokens)
When you are creating presentations, it is very important that you remember to always include the company logo in the top-right corner of each and every slide. The logo should be sized appropriately, typically around 100 pixels in height, and should not be too large or too small.

# ✓ Concise (40 tokens)
Include company logo in top-right corner of each slide (100px height).
```

2. **Use Tables:**
```markdown
# More token-efficient than prose
| Element | Size | Position | Color |
|---------|------|----------|-------|
| Logo    | 100px height | Top-right | Full color |
| Header  | 32pt | Top-center | #FF5733 |
| Body    | 16pt | Main area | #333333 |
```

3. **Reference External Resources:**
```markdown
# ✗ Embedding large content
## Complete Brand Style Guide
[1000 lines of detailed brand guidelines]

# ✓ Referencing (progressive disclosure)
## Brand Guidelines
See `resources/brand-style-guide.md` for complete guidelines.

Key points:
- Colors: Primary #FF5733, Secondary #333333
- Fonts: Helvetica for headers, Arial for body
- Logo: Always top-right, 100px height
```

---

## ◉ Supporting Files

Skills can include additional files beyond SKILL.md.

### Directory Structure

```
skill-name/
├── SKILL.md
├── resources/
│   ├── templates/
│   │   ├── presentation.pptx
│   │   ├── report.docx
│   │   └── email.html
│   ├── examples/
│   │   ├── good-example.md
│   │   └── bad-example.md
│   ├── reference/
│   │   ├── style-guide.md
│   │   └── api-docs.md
│   └── data/
│       └── constants.json
└── scripts/
    ├── validate.py
    ├── process.sh
    └── README.md
```

### Resource Types

**Templates:**
- Document templates (.docx, .xlsx, .pptx)
- HTML/CSS templates
- Configuration files

**Examples:**
- Sample inputs and outputs
- Good vs. bad examples
- Edge cases

**Reference Materials:**
- Style guides
- API documentation
- Technical specifications

**Data:**
- Constants and configuration
- Lookup tables
- Validation rules

**Scripts:**
- Python, Bash, JavaScript
- Validation and processing logic
- Helper utilities

### Script Integration

Claude can execute scripts in skills via the code execution environment.

**Example Python Script:**

`scripts/validate_email.py`:
```python
#!/usr/bin/env python3
"""Validate email format."""

import sys
import re

def validate_email(email):
    """Check if email has valid format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: validate_email.py <email>", file=sys.stderr)
        sys.exit(1)

    email = sys.argv[1]
    if validate_email(email):
        print(f"✓ Valid: {email}")
        sys.exit(0)
    else:
        print(f"✗ Invalid: {email}", file=sys.stderr)
        sys.exit(1)
```

**Referencing in SKILL.md:**
```markdown
## Email Validation

To validate email addresses, use the validation script:

```bash
python scripts/validate_email.py user@example.com
```

The script returns exit code 0 for valid emails, 1 for invalid.
```

**Benefits of Scripts:**
- More reliable than LLM generation for well-defined tasks
- Faster execution
- Script code doesn't consume tokens (only output does)
- Deterministic results

---

## ◉ Validation and Testing

### Frontmatter Validation

**Check YAML Syntax:**
```bash
# Extract and validate just the frontmatter
sed -n '/^---$/,/^---$/p' SKILL.md | python3 -c "import sys, yaml; yaml.safe_load(sys.stdin)"
```

**Validate Field Constraints:**
```python
#!/usr/bin/env python3
"""Validate SKILL.md frontmatter."""

import yaml
import sys

def validate_skill(filepath):
    with open(filepath) as f:
        content = f.read()

    # Extract frontmatter
    if not content.startswith('---\n'):
        print("ERROR: File must start with '---'")
        return False

    parts = content.split('---\n', 2)
    if len(parts) < 3:
        print("ERROR: Invalid frontmatter format")
        return False

    # Parse YAML
    try:
        metadata = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        print(f"ERROR: Invalid YAML: {e}")
        return False

    # Validate required fields
    if 'name' not in metadata:
        print("ERROR: Missing required field 'name'")
        return False

    if 'description' not in metadata:
        print("ERROR: Missing required field 'description'")
        return False

    # Validate constraints
    if len(metadata['name']) > 64:
        print(f"ERROR: name too long ({len(metadata['name'])} > 64)")
        return False

    if len(metadata['description']) > 1024:
        print(f"ERROR: description too long ({len(metadata['description'])} > 1024)")
        return False

    if ' ' in metadata['name']:
        print("WARNING: name contains spaces, use hyphens instead")

    print("✓ Validation passed")
    return True

if __name__ == '__main__':
    validate_skill(sys.argv[1])
```

### Content Testing

**Test Skill Activation:**

1. Create test conversation
2. Use skill trigger words from description
3. Verify skill loads correctly
4. Check output matches expectations

**Example Test Script:**
```bash
#!/bin/bash
# Test skill activation in Claude Code

echo "Testing brand-guidelines skill..."
echo "Create a branded PowerPoint presentation" | claude --print

# Check if skill was loaded (look in Claude's response)
# Should mention loading brand-guidelines skill
```

### Progressive Loading Test

Verify that resources load only when needed:

1. Activate skill with simple request
2. Check token usage
3. Request something that needs resources
4. Verify increased token usage
5. Confirm resources were loaded

---

## ◉ Complete Examples

### Example 1: Minimal Skill

`simple-greeter/SKILL.md`:
```markdown
---
name: simple-greeter
description: Generate friendly greetings in various languages; use when user requests greetings, hello messages, or multilingual salutations
---

# Simple Greeter

Generate friendly greetings.

## Languages Supported

- English: "Hello"
- Spanish: "Hola"
- French: "Bonjour"
- Indonesian: "Halo"
- Japanese: "こんにちは" (Konnichiwa)

## Instructions

When user requests a greeting:
1. Ask which language if not specified
2. Provide the greeting
3. Include pronunciation if non-Latin script
```

### Example 2: Skill with Resources

`brand-guidelines/SKILL.md`:
```markdown
---
name: brand-guidelines
description: Apply Okusi Group brand standards to all communications including colors (Orange #FF8C00, Navy #001f3f), fonts (Montserrat, Open Sans), and logo usage; use when creating branded content, marketing materials, presentations, or any external-facing documents
license: Proprietary - Internal Use Only
metadata:
  version: "1.5.0"
  organization: "Okusi Group"
  updated: "2025-10-19"
---

# Okusi Group Brand Guidelines

Ensure all content follows Okusi Group brand standards.

## Brand Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Orange | #FF8C00 | Headers, CTAs, highlights |
| Navy Blue | #001f3f | Body text, backgrounds |
| Light Gray | #F5F5F5 | Backgrounds, dividers |
| White | #FFFFFF | Text on dark backgrounds |

## Typography

- **Headers**: Montserrat Bold
- **Subheaders**: Montserrat Semi-Bold
- **Body**: Open Sans Regular
- **Captions**: Open Sans Italic

## Logo Usage

Logo files available in `resources/logos/`:
- `okusi-full-color.svg` - Primary logo
- `okusi-white.svg` - For dark backgrounds
- `okusi-icon.svg` - App icon / favicon

Rules:
- Minimum size: 100px width
- Clear space: Minimum 20px on all sides
- Never distort or recolor

## Document Templates

See `resources/templates/` for:
- PowerPoint: `presentation-template.pptx`
- Word: `report-template.docx`
- Email: `email-signature.html`

## Examples

See `resources/examples/` for reference implementations.
```

Directory structure:
```
brand-guidelines/
├── SKILL.md
└── resources/
    ├── logos/
    │   ├── okusi-full-color.svg
    │   ├── okusi-white.svg
    │   └── okusi-icon.svg
    ├── templates/
    │   ├── presentation-template.pptx
    │   ├── report-template.docx
    │   └── email-signature.html
    └── examples/
        ├── good-example.pdf
        └── bad-example.pdf
```

### Example 3: Skill with Scripts

`data-validator/SKILL.md`:
```markdown
---
name: data-validator
description: Validate CSV data files for completeness, format correctness, and business rules; use when user needs to check data quality, validate imports, or verify data before processing
allowed-tools: Read Bash
---

# Data Validator

Validate CSV data files according to business rules.

## Validation Steps

1. **Structure Validation**: Check file format and headers
2. **Data Type Validation**: Verify each column contains correct data types
3. **Business Rules**: Apply domain-specific validation
4. **Report**: Generate validation report

## Usage

To validate a CSV file:

```bash
python scripts/validate_csv.py data.csv
```

## Validation Rules

See `resources/validation-rules.json` for complete rule set.

### Required Columns

- `email`: Must be valid email format
- `phone`: Must match pattern `+XX XXX XXX XXXX`
- `date`: Must be ISO 8601 format `YYYY-MM-DD`

### Business Rules

- `age`: Must be 18-120
- `country_code`: Must be valid ISO 3166-1 alpha-2
- `amount`: Must be positive number

## Output Format

Validation script outputs JSON:

```json
{
  "valid": true,
  "total_rows": 1000,
  "errors": [],
  "warnings": [
    {"row": 42, "column": "phone", "message": "Non-standard format"}
  ]
}
```
```

Directory structure:
```
data-validator/
├── SKILL.md
├── resources/
│   ├── validation-rules.json
│   └── examples/
│       ├── valid-data.csv
│       └── invalid-data.csv
└── scripts/
    ├── validate_csv.py
    ├── check_business_rules.py
    └── requirements.txt
```

`scripts/validate_csv.py`:
```python
#!/usr/bin/env python3
"""CSV data validator."""

import sys
import csv
import json
import re
from datetime import datetime

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def validate_date(date_str):
    try:
        datetime.fromisoformat(date_str)
        return True
    except ValueError:
        return False

def validate_csv(filepath):
    errors = []
    warnings = []

    with open(filepath) as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=2):  # Start at 2 (1 is header)
            # Email validation
            if 'email' in row and not validate_email(row['email']):
                errors.append({
                    "row": i,
                    "column": "email",
                    "message": f"Invalid email: {row['email']}"
                })

            # Date validation
            if 'date' in row and not validate_date(row['date']):
                errors.append({
                    "row": i,
                    "column": "date",
                    "message": f"Invalid date format: {row['date']}"
                })

            # Age validation
            if 'age' in row:
                try:
                    age = int(row['age'])
                    if not 18 <= age <= 120:
                        errors.append({
                            "row": i,
                            "column": "age",
                            "message": f"Age out of range: {age}"
                        })
                except ValueError:
                    errors.append({
                        "row": i,
                        "column": "age",
                        "message": f"Invalid age: {row['age']}"
                    })

    result = {
        "valid": len(errors) == 0,
        "total_rows": i - 1,
        "errors": errors,
        "warnings": warnings
    }

    print(json.dumps(result, indent=2))
    return result["valid"]

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: validate_csv.py <file.csv>", file=sys.stderr)
        sys.exit(1)

    valid = validate_csv(sys.argv[1])
    sys.exit(0 if valid else 1)
```

---

## ◉ Common Patterns

### Pattern: Style Guide Skill

```markdown
---
name: code-style-python
description: Enforce Python PEP 8 coding standards including naming conventions, indentation, line length, and documentation; use for Python code review, linting, or ensuring code quality
allowed-tools: Read
---

# Python Code Style Checker

Enforce PEP 8 standards.

## Key Rules

1. **Indentation**: 4 spaces (never tabs)
2. **Line Length**: Max 79 characters
3. **Naming**:
   - `snake_case` for functions and variables
   - `PascalCase` for classes
   - `UPPER_CASE` for constants
4. **Imports**: Standard library, third-party, local (in that order)
5. **Docstrings**: Use triple quotes `"""` for all public functions

## Checklist

- [ ] All functions have docstrings
- [ ] No lines exceed 79 characters
- [ ] Consistent naming conventions
- [ ] Proper import organization
- [ ] No unused imports
- [ ] Type hints on function signatures
```

### Pattern: Template Generator Skill

```markdown
---
name: email-template-generator
description: Generate professional email templates for various business scenarios including meeting requests, status updates, announcements, and follow-ups; use when user needs to compose business emails following corporate communication standards
---

# Email Template Generator

Create professional business email templates.

## Templates Available

See `resources/templates/` for complete templates:
- Meeting request: `meeting-request.md`
- Status update: `status-update.md`
- Announcement: `announcement.md`
- Follow-up: `follow-up.md`

## Standard Format

```
Subject: [Clear, concise subject line]

[Greeting]

[Opening paragraph - context and purpose]

[Main content - 2-3 paragraphs maximum]

[Call to action or next steps]

[Closing]
[Signature]
```

## Tone Guidelines

- **Internal**: Professional but friendly
- **External**: Formal and courteous
- **Executive**: Concise and direct
- **Team**: Collaborative and supportive
```

### Pattern: Validation Skill

```markdown
---
name: json-schema-validator
description: Validate JSON data against JSON Schema specifications including type checking, required fields, and custom validation rules; use when validating API responses, configuration files, or structured data
allowed-tools: Read Bash
---

# JSON Schema Validator

Validate JSON data against schemas.

## Usage

```bash
python scripts/validate_json.py data.json schema.json
```

## Output

Exit codes:
- `0`: Valid
- `1`: Invalid (errors printed to stderr)

## Common Schemas

Pre-defined schemas in `resources/schemas/`:
- `user-schema.json` - User data validation
- `config-schema.json` - Configuration file validation
- `api-response-schema.json` - API response validation
```

---

## ◉ Troubleshooting

### Skill Not Loading

**Symptoms:**
- Claude doesn't recognize the skill
- Skill not appearing in available skills list

**Solutions:**

1. **Check file location:**
```bash
# Personal skills
ls -la ~/.claude/skills/your-skill/SKILL.md

# Project skills
ls -la .claude/skills/your-skill/SKILL.md
```

2. **Verify frontmatter:**
```bash
head -20 SKILL.md
# Should show valid YAML frontmatter
```

3. **Restart Claude Code:**
```bash
# Skills are loaded at startup
# Restart to pick up changes
```

4. **Check name matches directory:**
```bash
# Directory: brand-guidelines
# SKILL.md must have: name: brand-guidelines
```

### Skill Loads but Doesn't Activate

**Symptoms:**
- Skill appears in list
- Doesn't activate when it should

**Solutions:**

1. **Improve description triggers:**
```yaml
# ✗ Vague
description: Helps with presentations

# ✓ Specific triggers
description: Create PowerPoint presentations; use when user mentions slides, PowerPoint, presentations, or pitch decks
```

2. **Use skill name in request:**
```
User: "Use the brand-guidelines skill to create a presentation"
```

3. **Make request more specific:**
```
# ✗ Too generic
User: "Create a document"

# ✓ Matches skill description
User: "Create a branded PowerPoint presentation for Q3 results"
```

### YAML Parsing Errors

**Common errors and fixes:**

```yaml
# ERROR: mapping values are not allowed here
description: Error: This breaks YAML
# FIX: Quote the value
description: "Error: This works fine"

# ERROR: could not find expected ':'
name brand-guidelines
# FIX: Add colon
name: brand-guidelines

# ERROR: found character '\t' that cannot start any token
	name: skill
# FIX: Use spaces not tabs
  name: skill
```

### Token Limit Exceeded

**Symptoms:**
- Skill cuts off mid-instruction
- Resources not loading

**Solutions:**

1. **Move detailed content to resources:**
```markdown
# ✗ Embedding large content
## Complete Style Guide
[5000 lines of content]

# ✓ Reference resource
## Style Guide
See `resources/complete-style-guide.md` for details.

Key points:
- Use blue (#001f3f)
- Max 80 char lines
```

2. **Use tables instead of prose:**
```markdown
# More efficient
| Rule | Value |
|------|-------|
| Max line length | 80 |
| Indent | 4 spaces |
```

3. **Leverage scripts:**
```markdown
# Script code doesn't consume tokens
Use validation script: `scripts/validate.py`
```

---

## ◉ Best Practices Summary

### DO:

- ✓ Use hyphen-case for skill names
- ✓ Write descriptions in third person
- ✓ Include trigger words in description
- ✓ Keep instructions under 5,000 tokens
- ✓ Provide concrete examples
- ✓ Use relative paths for resources
- ✓ Validate YAML syntax
- ✓ Test skill activation
- ✓ Version your skills (metadata)

### DON'T:

- ✗ Use spaces in skill names
- ✗ Write vague descriptions
- ✗ Embed large content directly
- ✗ Use absolute file paths
- ✗ Forget to quote special characters
- ✗ Mix tabs and spaces
- ✗ Skip examples
- ✗ Omit testing

---

**Navigation:**
- [← Back to Overview](01-Overview.md)
- [Next: Architecture & Progressive Disclosure →](03-Architecture-Progressive-Disclosure.md)

#fin
