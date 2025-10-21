# Claude Skills - Overview and Introduction

**Last Updated:** October 19, 2025
**Status:** Feature Preview

---

## Table of Contents

1. [What Are Claude Skills?](#what-are-claude-skills)
2. [Announcement and Timeline](#announcement-and-timeline)
3. [Core Concepts](#core-concepts)
4. [Availability and Pricing](#availability-and-pricing)
5. [Key Features](#key-features)
6. [Use Cases](#use-cases)
7. [Platform Support](#platform-support)
8. [Why Skills Matter](#why-skills-matter)

---

## ◉ What Are Claude Skills?

Claude Skills are **modular, reusable capability packages** that teach Claude how to perform specific tasks in a repeatable, consistent way. Each skill is a folder containing:

- **Instructions** - Detailed guidance in SKILL.md (Markdown with YAML frontmatter)
- **Scripts** - Optional executable code for tasks where programming is more reliable than token generation
- **Resources** - Supporting files like templates, style guides, reference documents, examples

### The Problem Skills Solve

Before Skills, users faced three challenges when customizing Claude:

1. **Repetition** - Had to provide the same detailed instructions in every conversation
2. **Inconsistency** - No guarantee Claude would follow the same process each time
3. **Token Waste** - Large instruction sets consumed valuable context window space

### The Skills Solution

Skills enable:
- **Reusability** - Write instructions once, use across all interactions
- **Consistency** - Claude follows the same process every time a skill is invoked
- **Efficiency** - Progressive disclosure loads only what's needed, when needed
- **Portability** - Same skill works across Claude.ai, API, and Claude Code

---

## ◉ Announcement and Timeline

### Official Announcement

**Date:** October 16, 2025
**Source:** Anthropic official blog
**Availability:** Immediate (Feature Preview)

### Key Milestones

| Date | Event |
|------|-------|
| October 16, 2025 | Official announcement and feature preview launch |
| October 16, 2025 | anthropics/skills repository published on GitHub |
| October 16, 2025 | API beta access enabled for all paid plans |
| October 16, 2025 | Claude Code beta integration activated |

### Current Status

**As of October 19, 2025** (3 days after announcement):
- ✓ Available in Feature Preview across all paid plans
- ✓ Working in Claude.ai, API, and Claude Code
- ✓ Official examples published and documented
- ⦿ Rapidly evolving - expect frequent updates to documentation and capabilities

---

## ◉ Core Concepts

### 1. Progressive Disclosure

Skills use a **three-tier loading model** that minimizes token usage:

#### Tier 1: Metadata (Always Loaded)
- **Name**: Skill identifier (max 64 characters)
- **Description**: When and why to use this skill (max 1024 characters)
- **Cost**: Minimal (~50-100 tokens per skill)

At startup, Claude pre-loads name and description for ALL installed skills into the system prompt. This provides just enough information for Claude to know when each skill should be used.

#### Tier 2: Full Instructions (Loaded When Relevant)
- **Content**: Complete SKILL.md body
- **Size**: Recommended <5,000 tokens
- **Trigger**: Claude autonomously loads when skill matches the task

When Claude determines a skill is relevant, it loads the complete instruction set.

#### Tier 3: Resources (Loaded On-Demand)
- **Content**: Referenced files, templates, examples
- **Size**: Effectively unbounded
- **Trigger**: Loaded only when specifically needed

Additional resources are loaded only if the instructions reference them and they're needed for the current task.

### 2. Model-Invoked Execution

Skills are **autonomously activated** by Claude:

```
User Request
     ↓
Claude Scans Available Skills (Tier 1: Metadata)
     ↓
Claude Matches Skill(s) to Task
     ↓
Claude Loads Full Instructions (Tier 2)
     ↓
Claude Executes Task Following Skill Guidelines
     ↓
(Optional) Claude Loads Resources (Tier 3)
     ↓
Result Returned to User
```

**Key Point:** Users don't explicitly invoke skills. Instead, Claude recognizes when a skill is relevant based on:
- Skill name mentioned in user request
- Description keywords matching the task
- Context suggesting the skill's purpose

### 3. Composability

Skills automatically **stack together**:

- Claude can use multiple skills simultaneously
- Skills coordinate without explicit orchestration
- Example: Using "brand-guidelines" + "powerpoint" skills together creates branded presentations

### 4. Portability

**Same format everywhere:**

| Platform | Personal Skills | Project Skills | Plugin Skills |
|----------|----------------|----------------|---------------|
| **Claude.ai** | Cloud storage | Team shared | Marketplace |
| **Claude Code** | ~/.claude/skills/ | .claude/skills/ | Plugin system |
| **API** | Uploaded via API | Container param | API reference |

Build a skill once, use it across all platforms without modification.

---

## ◉ Availability and Pricing

### Plan Comparison

| Plan | Claude.ai | Claude Code | API | Price Point |
|------|-----------|-------------|-----|-------------|
| **Free** | ✗ | ✗ | ✗ | $0 |
| **Pro** | ✓ | ✓ Beta | ✓ | $20/month |
| **Max** | ✓ | ✓ Beta | ✓ | Varies |
| **Team** | ✓ | ✓ Beta | ✓ | Per user |
| **Enterprise** | ✓ | ✓ Beta | ✓ | Custom |

### What's Included

**All Paid Plans Get:**
- ✓ Access to Anthropic-created skills (Excel, PowerPoint, Word, PDF)
- ✓ Ability to create custom skills
- ✓ Skill usage across all platforms
- ✓ Plugin marketplace access (Claude Code)
- ✓ API integration with code execution tool

**Enterprise Plans Additionally Get:**
- Team skill sharing and management
- Admin controls for skill deployment
- Custom skill development support
- Higher API rate limits

### Usage Limits

Skills consume tokens from your plan's allocation:

- **Pro Plan**: ~44,000 tokens per 5-hour period
- **Max Plan**: 88,000-220,000 tokens depending on tier
- **Enterprise**: Custom allocations

Each active skill costs:
- Metadata (Tier 1): ~50-100 tokens (always loaded)
- Instructions (Tier 2): ~1,000-5,000 tokens (when activated)
- Resources (Tier 3): Variable (when specifically needed)

---

## ◉ Key Features

### 1. Speed and Performance

**Faster Execution:**
- Skills can include executable scripts that run instantly
- No need to generate code via tokens for well-defined tasks
- Example: PDF form filling uses Python scripts instead of LLM generation

**Token Efficiency:**
- Only relevant skills loaded into context
- Progressive disclosure prevents context bloat
- Script execution output (not code) consumes tokens

### 2. Consistency and Reliability

**Repeatable Results:**
- Same instructions used every time
- Reduces variability in Claude's responses
- Crucial for business workflows

**Quality Assurance:**
- Test skills once, trust them forever
- Iterate and improve skills over time
- Version control for skill evolution

### 3. Domain Expertise

**Specialized Knowledge:**
- Package industry-specific expertise
- Company brand guidelines and standards
- Technical documentation and processes

**Example Domains:**
- Financial modeling and reporting
- Legal document generation
- Healthcare compliance workflows
- Software development patterns

### 4. Security and Control

**Restricted Capabilities:**
- `allowed-tools` field limits what Claude can do when skill is active
- Principle of least privilege
- Audit trail of skill usage

**Example:**
```yaml
---
name: safe-file-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
```

When this skill is active, Claude cannot use Write, Edit, or Bash tools.

---

## ◉ Use Cases

### Document Generation

**Branded PowerPoint Presentations:**
- Skill contains: Company template, brand colors, font guidelines
- User request: "Create Q3 results presentation"
- Result: Professionally formatted slides following brand standards

**Excel Spreadsheets with Formulas:**
- Skill contains: Excel best practices, formula reference, formatting rules
- User request: "Create financial model for 5-year projection"
- Result: Working spreadsheet with proper formulas and formatting

### Workflow Automation

**Internal Communications:**
- Skill contains: Company voice guidelines, email templates, approval processes
- User request: "Write status update for Q3 project milestones"
- Result: Properly formatted email following company standards

**Code Review:**
- Skill contains: Coding standards, security checklist, performance guidelines
- User request: "Review this pull request"
- Result: Comprehensive review following organization's standards

### Data Analysis

**Report Generation:**
- Skill contains: Report template, analysis methodology, visualization guidelines
- User request: "Analyze this sales data and create summary report"
- Result: Structured report with consistent analysis approach

### Creative Work

**Algorithmic Art:**
- Skill contains: p5.js patterns, generative art techniques, seeded randomness
- User request: "Create generative art piece with flow fields"
- Result: Unique artwork following specific artistic approach

### Development Tools

**MCP Server Creation:**
- Skill contains: MCP protocol specs, best practices, example patterns
- User request: "Create MCP server for Stripe API"
- Result: Well-structured, compliant MCP server implementation

---

## ◉ Platform Support

### Claude.ai (Web Interface)

**Location:** Settings → Capabilities → Skills

**Features:**
- Toggle pre-built Anthropic skills
- Upload custom skills
- Share team skills (Team/Enterprise plans)
- Cloud storage for personal skills

**Activation:**
- Automatic based on skill description matching
- Manual mention of skill name in prompt

### Claude Code (CLI)

**Location:**
- Personal: `~/.claude/skills/`
- Project: `.claude/skills/`
- Plugins: Via plugin marketplace

**Features:**
- Git-tracked project skills
- Plugin marketplace integration
- Local file system storage
- Automatic reload on changes

**Commands:**
```bash
/plugin marketplace add anthropics/skills
/plugin install @anthropics/skills/skill-name
```

### API (Messages API)

**Integration:** Via code execution tool

**Features:**
- Programmatic skill management
- Version control
- Up to 8 skills per request
- Container parameter for skill specification

**Example:**
```python
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    tools=[{"type": "code_execution"}],
    container={
        "skills": [
            {"type": "skill", "skill_id": "powerpoint", "version": "1.0"}
        ]
    },
    messages=[{"role": "user", "content": "Create presentation"}]
)
```

---

## ◉ Why Skills Matter

### 1. Democratization of AI Customization

**Before Skills:**
- Customizing AI required prompt engineering expertise
- Complex instructions needed in every conversation
- Inconsistent results

**With Skills:**
- Package expertise once, share with team
- No prompt engineering needed for end users
- Consistent, reliable results

### 2. Token Economics

**Progressive Disclosure Benefits:**
- Library of 100+ skills: ~5,000-10,000 tokens for all metadata
- Only 2-3 skills activated per task: +2,000-10,000 tokens
- Total: ~7,000-20,000 tokens vs. loading everything (~500,000+ tokens)

**Cost Savings:**
- Fewer tokens = lower API costs
- More context available for actual work
- Faster response times

### 3. Knowledge Management

**Organizational Knowledge:**
- Capture company processes and standards
- Evolve skills as processes improve
- Version control for change management

**Personal Productivity:**
- Create skills for repetitive tasks
- Build personal workflow library
- Share skills across projects

### 4. Comparison to MCP

**MCP (Model Context Protocol):**
- Complex protocol specification
- Requires server implementation
- Covers hosts, clients, servers, resources, prompts, tools
- Better for integrating external services and APIs

**Claude Skills:**
- Simple Markdown + YAML format
- No server infrastructure needed
- Focuses on task instructions and processes
- Better for workflow automation and document generation

**Relationship:**
- Skills can call MCP tools
- Complementary, not competing
- Skills = task abstraction
- MCP = integration mechanism

See [09-Skills-vs-MCP.md](09-Skills-vs-MCP.md) for detailed comparison.

---

## ◉ Industry Impact

### Early Reactions

**Simon Willison (AI researcher):**
> "Claude Skills are awesome, maybe a bigger deal than MCP. They're significantly simpler - Markdown with YAML metadata vs. a complex protocol specification."

**Key Observations:**
- Token efficiency via progressive disclosure
- Simplicity compared to alternatives
- Practical for real-world workflows

### Potential Applications

**Enterprise:**
- Compliance and regulatory workflows
- Brand consistency across organizations
- Automated reporting and analytics

**Development:**
- Code review and quality assurance
- Documentation generation
- Test automation

**Creative:**
- Content creation with style guidelines
- Design systems implementation
- Multi-step creative workflows

**Education:**
- Teaching methodology consistency
- Assignment grading workflows
- Curriculum-aligned responses

---

## ◉ Getting Started

### For End Users

1. **Enable Skills** (Claude.ai):
   - Settings → Capabilities → Skills
   - Toggle on relevant pre-built skills

2. **Use Skills** naturally:
   - "Create a PowerPoint about Q3 results"
   - "Generate Excel spreadsheet for budget tracking"
   - "Write branded email announcement"

3. **Provide Feedback**:
   - Skills improve based on usage
   - Report issues to Anthropic support

### For Skill Creators

1. **Start Simple**:
   - Create basic SKILL.md with clear instructions
   - Test with common use cases
   - Iterate based on results

2. **Add Complexity Gradually**:
   - Include example inputs/outputs
   - Add scripts for reliability
   - Reference resources as needed

3. **Follow Best Practices**:
   - See [06-Best-Practices.md](06-Best-Practices.md)
   - Study example skills in anthropics/skills
   - Test across different platforms

### For Organizations

1. **Identify Workflows**:
   - Document repetitive tasks
   - Capture domain expertise
   - Define quality standards

2. **Build Skill Library**:
   - Start with highest-value use cases
   - Create team-shared project skills
   - Maintain in version control

3. **Measure Impact**:
   - Track consistency improvements
   - Measure time savings
   - Gather user feedback

---

## ◉ What's Next

### Expected Evolution

**Short Term (Weeks):**
- More Anthropic-created skills
- Enhanced documentation and examples
- Community-contributed skills
- Plugin marketplace expansion

**Medium Term (Months):**
- Skill analytics and usage metrics
- Advanced composition features
- Improved discovery mechanisms
- Enterprise management tools

**Long Term (Quarters):**
- Industry-specific skill libraries
- Marketplace ecosystem
- Skill certification programs
- Advanced security and compliance features

### Resources for Learning

- **Official Documentation**: [docs.claude.com](https://docs.claude.com)
- **Example Repository**: [github.com/anthropics/skills](https://github.com/anthropics/skills)
- **Anthropic Academy**: Training courses and tutorials
- **Community**: Hacker News, Reddit r/ClaudeAI discussions

---

## ◉ Summary

Claude Skills represent a major advancement in AI customization:

**Key Takeaways:**
- ✓ **Announced** October 16, 2025 (just 3 days old!)
- ✓ **Available** across Claude.ai, API, and Claude Code
- ✓ **Accessible** to all paid plan subscribers
- ✓ **Simple** to create (Markdown + YAML)
- ✓ **Efficient** via progressive disclosure architecture
- ✓ **Portable** across all platforms
- ✓ **Composable** - skills work together automatically
- ✓ **Practical** - solves real workflow challenges

**Next Steps:**
1. Read [02-SKILL-Format-Specification.md](02-SKILL-Format-Specification.md) to understand the file format
2. Review [04-Installation-Setup.md](04-Installation-Setup.md) for setup instructions
3. Study [08-Example-Skills-Catalog.md](08-Example-Skills-Catalog.md) for inspiration
4. Follow [06-Best-Practices.md](06-Best-Practices.md) to create your first skill

---

**Navigation:**
- [← Back to README](00-README.md)
- [Next: SKILL Format Specification →](02-SKILL-Format-Specification.md)

#fin
