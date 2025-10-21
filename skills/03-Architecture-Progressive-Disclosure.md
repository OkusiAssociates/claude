# Claude Skills - Architecture and Progressive Disclosure

**Last Updated:** October 19, 2025
**Technical Specification Version:** 1.0

---

## Table of Contents

1. [Progressive Disclosure Overview](#progressive-disclosure-overview)
2. [Three-Tier Loading Model](#three-tier-loading-model)
3. [Token Efficiency](#token-efficiency)
4. [Skill Discovery and Selection](#skill-discovery-and-selection)
5. [Resource Loading Mechanism](#resource-loading-mechanism)
6. [Script Execution Architecture](#script-execution-architecture)
7. [Performance Optimization](#performance-optimization)
8. [Technical Implementation Details](#technical-implementation-details)

---

## ◉ Progressive Disclosure Overview

Progressive disclosure is the **core architectural principle** that makes Claude Skills scalable, efficient, and practical for real-world use.

### The Problem

Traditional approaches to AI customization face a fundamental constraint:

**The Context Window Dilemma:**
- Large language models have finite context windows (200K tokens for Claude 3.5)
- Loading all customization content upfront exhausts the context
- Example: 100 detailed instruction sets = ~500,000 tokens
- Result: No room left for actual work

### The Solution

Progressive disclosure solves this by **loading information in layers**:

1. **Startup**: Load minimal metadata for ALL skills (~50-100 tokens each)
2. **Discovery**: Claude scans metadata to find relevant skills
3. **Activation**: Load full instructions only for selected skills
4. **Execution**: Load resources only when specifically needed

### The Analogy

Think of progressive disclosure like a **well-organized library**:

#### Without Progressive Disclosure:
- You walk in and every book immediately opens in your face
- Thousands of pages competing for attention
- Impossible to focus on what you need
- Information overload

#### With Progressive Disclosure:
- You see the card catalog (metadata) - one line per book
- Find relevant books based on titles and summaries
- Pull only the specific books you need
- Open to specific pages as required
- Everything else stays on the shelf, consuming zero attention

---

## ◉ Three-Tier Loading Model

Skills use a **three-tier progressive loading architecture**:

```
┌─────────────────────────────────────────┐
│  TIER 1: METADATA (Always Loaded)      │
│  - Name (max 64 chars)                  │
│  - Description (max 1024 chars)         │
│  - Cost: ~50-100 tokens per skill       │
└─────────────────────────────────────────┘
              ↓ (Skill selected)
┌─────────────────────────────────────────┐
│  TIER 2: INSTRUCTIONS (Loaded on Match)│
│  - Full SKILL.md body                   │
│  - Recommended: <5,000 tokens           │
│  - Cost: Actual instruction size        │
└─────────────────────────────────────────┘
              ↓ (Resource referenced)
┌─────────────────────────────────────────┐
│  TIER 3: RESOURCES (Loaded on Demand)  │
│  - Templates, examples, references      │
│  - Size: Effectively unbounded          │
│  - Cost: Only when specifically accessed│
└─────────────────────────────────────────┘
```

### Tier 1: Metadata (Always Loaded)

**What's Included:**
- `name`: Skill identifier
- `description`: When and why to use this skill
- Optional: `license`, `allowed-tools`, `metadata` fields

**Token Cost:**
- Name: ~10-15 tokens
- Description: ~30-100 tokens
- Total per skill: ~50-100 tokens

**When Loaded:**
- At system initialization
- Before any user interaction
- Remains in context throughout session

**Purpose:**
- Enables skill discovery
- Allows Claude to match skills to tasks
- Minimal context consumption

**Example:**
```yaml
name: brand-guidelines  # ~5 tokens
description: Apply Okusi Group brand standards to all communications
including colors (Orange #FF8C00, Navy #001f3f), fonts (Montserrat,
Open Sans), and logo usage; use when creating branded content, marketing
materials, presentations, or any external-facing documents  # ~60 tokens
# Total: ~65 tokens
```

With 100 skills installed:
- Total Tier 1 cost: ~6,500 tokens
- Leaves ~193,500 tokens for actual work
- Acceptable overhead for massive capability library

### Tier 2: Full Instructions (Loaded When Relevant)

**What's Included:**
- Complete SKILL.md body (after frontmatter)
- Detailed instructions
- Guidelines and rules
- Inline examples
- Resource references

**Token Cost:**
- Recommended: <5,000 tokens
- Typical: 1,000-3,000 tokens
- Maximum practical: ~10,000 tokens

**When Loaded:**
- When Claude determines skill is relevant
- Based on description matching user request
- Typically 1-3 skills per conversation turn

**Purpose:**
- Provides complete guidance for task execution
- Includes all necessary instructions
- References to Tier 3 resources

**Example Token Math:**
```
Metadata (Tier 1):           100 tokens
Full Instructions (Tier 2): 3,000 tokens
-----------------------------------------
Total when activated:       3,100 tokens
```

For a typical task using 2 skills:
- Tier 1 (all 100 skills): ~6,500 tokens
- Tier 2 (2 active skills): ~6,000 tokens
- Total overhead: ~12,500 tokens
- Remaining: ~187,500 tokens for work

### Tier 3: Resources (Loaded On-Demand)

**What's Included:**
- Template files (.pptx, .docx, .xlsx, etc.)
- Reference documents
- Example files
- Configuration data
- Large reference materials

**Token Cost:**
- Variable: Depends on resource size
- Only counted when actually loaded
- Can be very large (>50,000 tokens for complex templates)

**When Loaded:**
- Only when specifically referenced in Tier 2 instructions
- Only when needed for current sub-task
- Not pre-emptively loaded

**Purpose:**
- Provide detailed reference without constant token cost
- Store large templates and examples
- Enable effectively unbounded skill content

**Example:**
```markdown
## Brand Colors

For complete brand guidelines, see `resources/brand-guide.md`

Quick reference:
- Primary: #FF8C00
- Secondary: #001f3f
```

**Loading Behavior:**
- Claude sees quick reference (counted in Tier 2)
- If more detail needed, loads `resources/brand-guide.md` (Tier 3)
- If never needed, file never loaded, zero token cost

---

## ◉ Token Efficiency

### Comparative Analysis

#### Traditional Approach: Load Everything

```
System Prompt:                    1,000 tokens
Skill 1 Instructions:            10,000 tokens
Skill 2 Instructions:            15,000 tokens
Skill 3 Instructions:             8,000 tokens
... (97 more skills):           450,000 tokens
─────────────────────────────────────────────
Total Before User Request:      484,000 tokens
Context Window (200K):          200,000 tokens
PROBLEM: Exceeds context window by 284,000 tokens
```

#### Progressive Disclosure Approach

```
System Prompt:                    1,000 tokens
Tier 1 (100 skills metadata):     6,500 tokens
─────────────────────────────────────────────
At Startup:                       7,500 tokens

After User Request (2 skills activated):
Tier 2 (Skill 1):                 3,000 tokens
Tier 2 (Skill 2):                 2,500 tokens
─────────────────────────────────────────────
Total Context Used:              13,000 tokens
Remaining Available:            187,000 tokens
```

**Efficiency Gain:**
- Traditional: Context exceeded by 284,000 tokens (impossible)
- Progressive: Only 13,000 tokens used (93.5% available)

### Real-World Example: Document Skills Library

**Scenario:** Company has comprehensive document generation skills

**Skills Library:**
- 10 PowerPoint variants (different templates)
- 15 Excel skills (various financial models)
- 20 Word skills (reports, proposals, memos)
- 30 Email templates (internal, external, executive)
- 25 Code generation skills (various languages)

Total: 100 skills

#### Without Progressive Disclosure:

```
Each skill averages 5,000 tokens
100 skills × 5,000 = 500,000 tokens
Context window: 200,000 tokens
IMPOSSIBLE: Requires 2.5x available context
```

#### With Progressive Disclosure:

```
TIER 1 (Always Loaded):
100 skills × 65 tokens = 6,500 tokens

TIER 2 (Typical Usage - 2 skills):
2 skills × 3,000 tokens = 6,000 tokens

TOTAL: 12,500 tokens (6.25% of context)
AVAILABLE FOR WORK: 187,500 tokens
```

### Script Execution Efficiency

Scripts provide additional token savings:

**LLM Code Generation:**
```
Request: "Validate this email address"
Claude generates code:             500 tokens
Claude executes code:             (no additional tokens)
Result returned:                    50 tokens
───────────────────────────────────────────────
Total: 550 tokens
```

**Pre-built Script:**
```
Request: "Validate this email address"
Claude references script: scripts/validate.py  (15 tokens)
Script code:                        0 tokens (not loaded into context)
Script executes:                    0 tokens (runs in sandbox)
Result returned:                   50 tokens
───────────────────────────────────────────────
Total: 65 tokens

SAVINGS: 485 tokens (88% reduction)
```

For repetitive validation tasks (100 emails):
- LLM generation: 55,000 tokens
- Pre-built script: 6,500 tokens
- **Savings: 88.2%**

---

## ◉ Skill Discovery and Selection

### Discovery Process

```
┌────────────────────────────────┐
│  User Request Received         │
│  "Create branded presentation" │
└────────────────────────────────┘
            ↓
┌────────────────────────────────────────────────┐
│  Claude Analyzes Request                       │
│  - Keywords: "branded", "presentation"         │
│  - Intent: Document creation                   │
│  - Context: Professional/business              │
└────────────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────────────────┐
│  Claude Scans Tier 1 Metadata (All 100 Skills)      │
│  - Searches descriptions for matching keywords       │
│  - Scores relevance for each skill                   │
│  - Ranks by match quality                            │
└──────────────────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────────────┐
│  Selection Decision                              │
│  HIGH MATCH:                                     │
│    - "brand-guidelines" (mentions branded, docs) │
│    - "powerpoint-advanced" (mentions presentation)│
│  MEDIUM MATCH:                                   │
│    - "document-formatter" (general docs)         │
│  LOW MATCH:                                      │
│    - "email-templates" (different document type) │
└──────────────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────┐
│  Load Selected Skills (Tier 2)          │
│  - Load "brand-guidelines" full content  │
│  - Load "powerpoint-advanced" content    │
│  Total: 2 skills loaded                  │
└──────────────────────────────────────────┘
            ↓
┌────────────────────────────────┐
│  Execute Task Using Skills     │
│  - Follow loaded instructions  │
│  - Load Tier 3 resources if    │
│    referenced and needed       │
└────────────────────────────────┘
```

### Matching Algorithms

**Keyword Matching:**
- Description contains exact words from user request
- Example: User says "PowerPoint" → matches skills with "PowerPoint" in description

**Semantic Matching:**
- Related concepts even without exact words
- Example: User says "slides" → matches skills mentioning "presentation"

**Context Awareness:**
- Previous conversation context influences selection
- Example: If previously discussing branding → increases "brand-guidelines" relevance

**Explicit Invocation:**
- User mentions skill name directly
- Example: "Use the brand-guidelines skill to..." → guaranteed selection

### Trigger Optimization

**Good Triggers (High Match Rate):**
```yaml
description: Generate Excel financial models with formulas and charts;
use when user requests spreadsheets, financial analysis, budgets,
forecasts, or data analysis requiring calculations
```

**Trigger words:** spreadsheets, financial analysis, budgets, forecasts, Excel, formulas, charts

**Poor Triggers (Low Match Rate):**
```yaml
description: Helps with Excel stuff
```

**Trigger words:** Excel, stuff (too vague)

### Multi-Skill Composition

Skills automatically compose:

**Example Request:** "Create a branded financial report presentation"

**Skills Activated:**
1. `brand-guidelines` - Ensures brand compliance
2. `powerpoint-advanced` - Handles presentation creation
3. `financial-reporting` - Provides financial content structure

**Coordination:**
- Skills don't conflict (each handles different aspect)
- Claude synthesizes guidelines from all three
- Result: Branded financial PowerPoint following all standards

---

## ◉ Resource Loading Mechanism

### On-Demand Loading

Resources are loaded using **lazy evaluation**:

```markdown
## Brand Colors

Quick reference:
- Primary: #FF8C00
- Secondary: #001f3f

For complete guidelines, see `resources/brand-complete.md`
```

**Scenario 1: Simple Request**
```
User: "What's the primary brand color?"
Claude: Reads Tier 2 quick reference: "#FF8C00"
Resource load: NONE
Token cost: 0 additional tokens
```

**Scenario 2: Detailed Request**
```
User: "Provide complete brand color guidelines including accessibility"
Claude: Needs more info than quick reference
Loads: resources/brand-complete.md
Token cost: +5,000 tokens (only this one resource)
```

### Reference Patterns

**File References:**
```markdown
See `resources/template.pptx` for layout structure
Check `resources/examples/good-example.pdf` for reference
Run `scripts/validate.py` for validation
```

**When Referenced:**
- Claude recognizes file path
- Evaluates if file content needed
- Loads only if necessary for current sub-task

**Loading Decision Tree:**
```
Reference encountered: `resources/style-guide.md`
    ↓
Is content needed for current task?
    ↓                    ↓
   YES                  NO
    ↓                    ↓
Load file          Don't load file
Add to context     Zero token cost
```

### Practical Example

**Skill: `powerpoint-advanced`**

```markdown
## Slide Layouts

Standard layouts:
- Title slide: Centered title, subtitle, logo bottom-right
- Section header: Large centered heading, minimal decoration
- Content slide: Title top, bullet points or images

For detailed layout specifications, see:
- `resources/layouts/title-slide-spec.md`
- `resources/layouts/content-slide-spec.md`
- `resources/layouts/section-header-spec.md`

## Examples

See `resources/examples/` for complete presentation samples.
```

**User Request 1:** "Create a simple title slide"
- Loads: Tier 2 instructions (has basic title slide info)
- Loads: None from Tier 3 (basic info sufficient)
- Token cost: ~3,000 (Tier 2 only)

**User Request 2:** "Create a title slide with exact pixel measurements"
- Loads: Tier 2 instructions
- Loads: `resources/layouts/title-slide-spec.md` (detailed specs needed)
- Token cost: ~3,000 (Tier 2) + ~2,000 (resource) = ~5,000

**User Request 3:** "Show me example presentations"
- Loads: Tier 2 instructions
- Loads: Files from `resources/examples/`
- Token cost: ~3,000 (Tier 2) + ~10,000 (examples) = ~13,000

---

## ◉ Script Execution Architecture

### Execution Environment

Scripts run in **isolated code execution environment**:

```
┌─────────────────────────────────────────┐
│  Claude (LLM)                           │
│  - Reads SKILL.md                       │
│  - Decides to run script                │
│  - Calls code execution tool            │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  Code Execution Container               │
│  - Isolated sandbox                     │
│  - Pre-installed: Python, Node, etc.    │
│  - Access to skill's scripts/           │
│  - Executes script                      │
│  - Returns output                       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  Claude (LLM)                           │
│  - Receives script output               │
│  - Only output consumes tokens          │
│  - Script code never loaded to context  │
└─────────────────────────────────────────┘
```

### Token Efficiency of Scripts

**Key Insight:** Script code doesn't consume context tokens during execution.

**Example:**

`scripts/validate_email.py` (100 lines, ~3,000 tokens if loaded as text):
```python
#!/usr/bin/env python3
import re
import sys

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

# ... 90 more lines ...

if __name__ == '__main__':
    email = sys.argv[1]
    if validate_email(email):
        print(f"✓ Valid: {email}")
        sys.exit(0)
    else:
        print(f"✗ Invalid: {email}", file=sys.stderr)
        sys.exit(1)
```

**Usage in SKILL.md (Tier 2):**
```markdown
## Email Validation

To validate emails, run:
```bash
python scripts/validate_email.py <email>
```
# ~30 tokens in SKILL.md
```

**Execution:**
```
Request: "Validate user@example.com"
    ↓
Claude reads instruction (~30 tokens)
    ↓
Claude calls code execution:
  python scripts/validate_email.py user@example.com
    ↓
Script executes (script code: 0 tokens consumed)
    ↓
Output returned: "✓ Valid: user@example.com" (~10 tokens)
    ↓
Total token cost: ~40 tokens

vs. LLM generating validation code: ~500 tokens
SAVINGS: 92%
```

### Script Types and Use Cases

**Validation Scripts:**
- Email format validation
- Data type checking
- Schema validation
- Business rule enforcement

**Transformation Scripts:**
- Data format conversion
- File processing
- Template rendering
- Content generation

**Analysis Scripts:**
- Statistical calculations
- Data aggregation
- Compliance checking
- Quality metrics

**Integration Scripts:**
- API calls
- Database queries
- File system operations
- External tool invocation

---

## ◉ Performance Optimization

### Optimization Strategies

#### 1. Minimize Tier 1 Size

**Goal:** Keep all metadata under 10,000 tokens total

**Strategy:**
- Concise descriptions (target 50-70 tokens each)
- Essential trigger words only
- Remove filler words

**Example:**
```yaml
# ✗ Verbose (120 tokens)
description: This skill is designed to help you create professional,
high-quality PowerPoint presentations that follow the company's official
brand guidelines, ensuring consistency across all marketing materials and
external communications, including proper use of colors, fonts, and logos

# ✓ Concise (50 tokens)
description: Create branded PowerPoint presentations following company
guidelines for colors, fonts, and logos; use for marketing materials
and external communications
```

#### 2. Optimize Tier 2 Content

**Goal:** Keep instructions under 5,000 tokens

**Strategies:**

**Use Tables:**
```markdown
# ✗ Prose (200 tokens)
The primary color should be orange with hex value #FF8C00 and should be
used for headers and highlights. The secondary color is navy blue with
hex value #001f3f and should be used for body text...

# ✓ Table (60 tokens)
| Color | Hex | Usage |
|-------|-----|-------|
| Orange | #FF8C00 | Headers, highlights |
| Navy | #001f3f | Body text |
```

**Reference Resources:**
```markdown
# ✗ Embedded (5,000 tokens)
## Complete Email Templates
[100 different email templates inline]

# ✓ Referenced (100 tokens)
## Email Templates
See `resources/templates/` for complete collection.

Common templates:
- Meeting request: `templates/meeting.md`
- Status update: `templates/status.md`
```

**Use Scripts:**
```markdown
# ✗ Include algorithm (500 tokens)
## Validation Algorithm
To validate emails, follow these steps:
1. Check for @ symbol
2. Verify domain has .
3. Ensure valid characters
[detailed algorithm]

# ✓ Reference script (30 tokens)
## Validation
Run: `python scripts/validate_email.py <email>`
```

#### 3. Lazy Resource Loading

**Goal:** Load resources only when absolutely necessary

**Strategy:**

```markdown
## Brand Guidelines

### Quick Reference (Always available in Tier 2)
- Primary: #FF8C00
- Secondary: #001f3f
- Font: Montserrat

### Detailed Guidelines (Tier 3 - loaded on demand)
For complete specifications, see:
- `resources/brand/colors-complete.md` - Full color palette with accessibility
- `resources/brand/typography.md` - Font usage, sizes, line heights
- `resources/brand/logo-usage.md` - Logo placement, spacing, variations
```

**Loading Behavior:**
- Basic branded content: Uses quick reference (0 Tier 3 tokens)
- Detailed brand compliance: Loads specific resource files (only what's needed)
- Full brand audit: Loads all resources (still more efficient than having them in Tier 2)

### Performance Metrics

**Skill Library Scaling:**

| Skills | Tier 1 Tokens | Activated (2) | Total | % of 200K |
|--------|---------------|---------------|-------|-----------|
| 10 | 650 | 6,000 | 6,650 | 3.3% |
| 50 | 3,250 | 6,000 | 9,250 | 4.6% |
| 100 | 6,500 | 6,000 | 12,500 | 6.3% |
| 500 | 32,500 | 6,000 | 38,500 | 19.3% |
| 1,000 | 65,000 | 6,000 | 71,000 | 35.5% |

**Key Insight:** Can have 500 skills installed and still use <20% of context window.

---

## ◉ Technical Implementation Details

### Skill Loading Lifecycle

```
1. INITIALIZATION
   ├─ Scan skill directories (~/.claude/skills, .claude/skills)
   ├─ Parse YAML frontmatter from each SKILL.md
   ├─ Load Tier 1 (name + description) into system prompt
   └─ Index skills for fast lookup

2. REQUEST PROCESSING
   ├─ User submits request
   ├─ Claude analyzes request semantics
   ├─ Scores each skill based on description match
   └─ Selects top matching skills

3. SKILL ACTIVATION
   ├─ Load Tier 2 (full SKILL.md body) for selected skills
   ├─ Inject instructions into working context
   ├─ Note any resource references
   └─ Begin task execution

4. RESOURCE LOADING (As Needed)
   ├─ Instruction references resource file
   ├─ Evaluate if content needed for current sub-task
   ├─ If yes: Load Tier 3 resource into context
   └─ If no: Skip loading (zero token cost)

5. SCRIPT EXECUTION (As Needed)
   ├─ Instruction indicates script should run
   ├─ Call code execution tool with script path
   ├─ Script runs in sandbox (code not loaded to context)
   ├─ Output returned to Claude
   └─ Output (not code) counted in tokens
```

### Storage and Indexing

**Skill Storage:**
```
~/.claude/skills/            # Personal skills
├── skill-1/
│   └── SKILL.md
├── skill-2/
│   └── SKILL.md
└── skill-3/
    └── SKILL.md

.claude/skills/              # Project skills
├── project-skill-1/
│   └── SKILL.md
└── project-skill-2/
    └── SKILL.md
```

**In-Memory Index:**
```json
{
  "skills": [
    {
      "id": "skill-1",
      "name": "brand-guidelines",
      "description": "Apply brand standards...",
      "path": "~/.claude/skills/skill-1/SKILL.md",
      "tier1_tokens": 65,
      "tier2_path": "~/.claude/skills/skill-1/SKILL.md",
      "tier2_tokens": 3200,
      "resources": [
        "resources/brand-guide.md",
        "resources/logo.svg"
      ]
    }
  ]
}
```

### Context Management

**System Prompt Structure:**
```
[Base System Prompt]
[Tier 1: All Skill Metadata - ~6,500 tokens for 100 skills]
[Conversation History]
[Current User Request]
[Tier 2: Activated Skills - ~3,000-6,000 tokens for 1-2 skills]
[Tier 3: Loaded Resources - variable, only if needed]
```

**Token Budget:**
```
Total Context Window:        200,000 tokens
Base System Prompt:            1,000 tokens
Tier 1 (100 skills):           6,500 tokens
Conversation History:         20,000 tokens
Current Request:                 500 tokens
Tier 2 (2 active skills):      6,000 tokens
Tier 3 (1 resource):           5,000 tokens
───────────────────────────────────────────
Total Used:                   39,000 tokens
Available for Response:      161,000 tokens
```

---

## ◉ Summary

Progressive disclosure makes Claude Skills practical by:

**1. Scalability**
- Support hundreds of skills without context exhaustion
- Add new skills without impacting existing ones
- Tier 1 overhead minimal (~65 tokens per skill)

**2. Efficiency**
- Load only what's needed, when needed
- Script code doesn't consume context tokens
- Resource files loaded on-demand

**3. Performance**
- Fast skill discovery (lightweight metadata scan)
- Quick activation (only selected skills loaded)
- Minimal latency impact

**4. Flexibility**
- Effectively unbounded skill content via Tier 3
- Skills can include massive reference materials
- No practical limit on resource file sizes

**5. Cost Optimization**
- Fewer tokens = lower API costs
- More context available for actual work
- Better token efficiency than alternative approaches

**Key Numbers:**
- 100 skills: ~6,500 tokens (Tier 1)
- 2 active skills: ~6,000 tokens (Tier 2)
- Total overhead: ~12,500 tokens (6.25% of 200K context)
- Remaining for work: 187,500 tokens (93.75%)

---

**Navigation:**
- [← Back to SKILL Format](02-SKILL-Format-Specification.md)
- [Next: Installation & Setup →](04-Installation-Setup.md)

#fin
