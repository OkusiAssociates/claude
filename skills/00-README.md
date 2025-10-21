# Claude Skills - Comprehensive Research Documentation

**Research Date:** October 19, 2025
**Feature Announcement:** October 16, 2025 (3 days old!)
**Researcher:** Gary Dean, Okusi Group

---

## ◉ About This Documentation

This comprehensive documentation set provides deep research into **Claude Skills**, Anthropic's groundbreaking new feature for customizing Claude's capabilities across all platforms. Claude Skills represents a major advancement in AI agent customization, potentially more significant than the Model Context Protocol (MCP).

## ◉ What Are Claude Skills?

Claude Skills are modular, reusable capabilities packaged as folders containing:
- **SKILL.md** - Markdown file with YAML frontmatter containing instructions
- **Scripts** - Optional executable code for reliable task execution
- **Resources** - Templates, reference documents, and supporting files

Skills use **progressive disclosure** architecture - Claude sees only skill names and descriptions initially, then autonomously loads full instructions and resources only when needed, keeping context windows efficient.

---

## ◉ Documentation Index

### Core Documentation

| File | Description |
|------|-------------|
| **[01-Overview.md](01-Overview.md)** | Introduction, announcement details, availability, key concepts, and fundamental architecture |
| **[02-SKILL-Format-Specification.md](02-SKILL-Format-Specification.md)** | Complete YAML frontmatter specification, required/optional fields, file structure, validation |
| **[03-Architecture-Progressive-Disclosure.md](03-Architecture-Progressive-Disclosure.md)** | Three-tier loading model, token efficiency, technical design philosophy, performance benefits |
| **[04-Installation-Setup.md](04-Installation-Setup.md)** | Directory structures, personal vs project skills, installation methods, plugin marketplace |

### Advanced Topics

| File | Description |
|------|-------------|
| **[05-API-Integration.md](05-API-Integration.md)** | Messages API usage, code execution tool, container parameter, programmatic skill management |
| **[06-Best-Practices.md](06-Best-Practices.md)** | Writing effective skills, description guidelines, testing strategies, iterative development |
| **[07-Security-Permissions.md](07-Security-Permissions.md)** | allowed-tools field, security considerations, permission management, least privilege principles |

### Reference Materials

| File | Description |
|------|-------------|
| **[08-Example-Skills-Catalog.md](08-Example-Skills-Catalog.md)** | Comprehensive catalog of example skills from anthropics/skills repository |
| **[09-Skills-vs-MCP.md](09-Skills-vs-MCP.md)** | Comparison with Model Context Protocol, use cases, complementary architecture |
| **[10-Limitations-Constraints.md](10-Limitations-Constraints.md)** | Token limits, API rate limits, restrictions, known issues, workarounds |
| **[11-Quick-Reference.md](11-Quick-Reference.md)** | Cheat sheet with templates, commands, common patterns, quick examples |

---

## ◉ Quick Start

### For Claude.ai Users
1. Navigate to **Settings → Capabilities → Skills**
2. Toggle on pre-built example skills (PowerPoint, Excel, Word, PDF)
3. Reference skill names in your prompts
4. Claude automatically loads and uses relevant skills

### For Claude Code Users
```bash
# Install skills from marketplace
/plugin marketplace add anthropics/skills
/plugin install @anthropics/skills/skill-name

# Or manually add to personal skills
mkdir -p ~/.claude/skills/my-skill
vim ~/.claude/skills/my-skill/SKILL.md
```

### For API Users
```python
# Use skills with code execution tool
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    tools=[{"type": "code_execution"}],
    tool_choice={"type": "any", "name": "code_execution"},
    container={
        "skills": [
            {"type": "skill", "skill_id": "skill-name", "version": "1.0"}
        ]
    },
    messages=[{"role": "user", "content": "Your request"}]
)
```

---

## ◉ Key Features

### ✓ Progressive Disclosure
- **Metadata Level**: Name (64 chars) + Description (1024 chars)
- **Instructions Level**: Full SKILL.md content (<5k tokens)
- **Resources Level**: Linked files loaded only when needed

### ✓ Platform Portability
- Same skill format across Claude.ai, API, and Claude Code
- Build once, use everywhere
- Personal skills: `~/.claude/skills/`
- Project skills: `.claude/skills/` (git-tracked)

### ✓ Composability
- Skills stack together automatically
- Claude coordinates multiple skills
- Up to 8 skills per API request

### ✓ Token Efficiency
- Only relevant skills loaded into context
- Script code doesn't consume tokens during execution
- Effectively unbounded skill content via progressive loading

---

## ◉ Availability

| Plan | Claude.ai | Claude Code | API |
|------|-----------|-------------|-----|
| **Free** | ✗ No | ✗ No | ✗ No |
| **Pro** | ✓ Yes | ✓ Yes (Beta) | ✓ Yes |
| **Max** | ✓ Yes | ✓ Yes (Beta) | ✓ Yes |
| **Team** | ✓ Yes | ✓ Yes (Beta) | ✓ Yes |
| **Enterprise** | ✓ Yes | ✓ Yes (Beta) | ✓ Yes |

**Status:** Feature Preview (as of October 16, 2025)

---

## ◉ Official Resources

- **Documentation**: [docs.claude.com/en/docs/agents-and-tools/agent-skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills)
- **GitHub Repository**: [github.com/anthropics/skills](https://github.com/anthropics/skills)
- **Announcement**: [anthropic.com/news/skills](https://www.anthropic.com/news/skills)
- **Engineering Deep Dive**: [anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- **API Guide**: [docs.claude.com/en/api/skills-guide](https://docs.claude.com/en/api/skills-guide)
- **Help Center**: [support.claude.com](https://support.claude.com) (search "Skills")

---

## ◉ Community Analysis

**Simon Willison's Take:**
> "Claude Skills are awesome, maybe a bigger deal than MCP"

Skills are significantly simpler than MCP - they're Markdown with YAML metadata vs. a complex protocol specification. The token efficiency (auto-detection and progressive loading) and simplicity make them potentially more practical for many use cases.

---

## ◉ Documentation Icons Legend

| Icon | Meaning |
|------|---------|
| ◉ | Information |
| ⦿ | Debug/Technical Detail |
| ▲ | Warning/Caution |
| ✓ | Success/Confirmed |
| ✗ | Error/Not Available |

---

## ◉ Research Methodology

This documentation was created through:
1. **Web searches** focused on content from October 13-19, 2025
2. **Official Anthropic documentation** analysis
3. **Community discussions** (Hacker News, blogs, technical forums)
4. **Example repository** examination (anthropics/skills)
5. **Comparative analysis** with related technologies (MCP)

All information has been verified against multiple sources where possible.

---

## ◉ Updates and Maintenance

Given that Claude Skills was announced just 3 days ago, this documentation represents the state of knowledge as of **October 19, 2025**. Expect rapid evolution of:
- API endpoints and parameters
- Skill format specifications
- Available example skills
- Best practices and patterns

Check official Anthropic resources for the latest updates.

---

## ◉ Contributing

This documentation is maintained as part of the Okusi Group's Claude Code toolkit. For questions or corrections, contact Gary Dean.

---

**Last Updated:** October 19, 2025
**Version:** 1.0
**Status:** Initial Research Documentation

#fin
