# Claude Skills vs Model Context Protocol (MCP)

**Last Updated:** October 19, 2025

---

## ◉ Overview

Claude Skills and Model Context Protocol (MCP) are **complementary technologies** that serve different purposes in the Claude ecosystem.

**Simon Willison's Take:**
> "Claude Skills are awesome, maybe a bigger deal than MCP"

---

## ◉ Quick Comparison

| Aspect | Claude Skills | MCP |
|--------|--------------|-----|
| **Purpose** | Task instructions & workflows | External integrations |
| **Complexity** | Simple (Markdown + YAML) | Complex (Protocol spec) |
| **Format** | SKILL.md files | Server/client architecture |
| **Token Usage** | Progressive disclosure | All loaded upfront |
| **Setup** | Drop files in directory | Server implementation required |
| **Use Case** | Repeatableprocesses | External data/tools |
| **Architecture** | File-based | Network-based |

---

## ◉ What is MCP?

**Model Context Protocol** is a comprehensive protocol specification for connecting LLMs to external resources.

### MCP Components

- **Hosts** - Applications using MCP (Claude Desktop, IDEs)
- **Clients** - MCP client implementations
- **Servers** - Provide resources, prompts, and tools
- **Resources** - Data sources (files, APIs, databases)
- **Prompts** - Templated interactions
- **Tools** - Callable functions
- **Transports** - Communication methods (stdio, HTTP, SSE)

### Example MCP Use Case

```
GitHub MCP Server:
- Resources: Repository contents, issues, PRs
- Tools: Create issue, comment on PR, merge
- Prompts: PR review template, issue triage

Claude Desktop connects to GitHub MCP Server
→ Can read repo, create issues, review PRs
```

### Token Cost

**Problem:** MCP servers can be token-heavy

"GitHub's official MCP on its own famously consumes tens of thousands of tokens of context, and once you've added a few more to that there's precious little space left for the LLM to actually do useful work."

---

## ◉ What are Claude Skills?

**Claude Skills** are modular capability packages with instructions, scripts, and resources.

### Skills Components

- **SKILL.md** - Instructions (Markdown + YAML)
- **Scripts** - Executable code
- **Resources** - Templates, references, examples

### Example Skill Use Case

```
Brand Guidelines Skill:
- Instructions: How to apply brand standards
- Resources: Logo files, color palette, templates
- Scripts: Validate brand compliance

Claude loads skill when creating branded content
→ Follows guidelines automatically
```

### Token Cost

**Benefit:** Progressive disclosure minimizes tokens

- Tier 1 (metadata): ~65 tokens per skill
- Tier 2 (instructions): ~3,000 tokens when activated
- Tier 3 (resources): Only when specifically needed

100 skills = ~6,500 tokens metadata, only 2-3 activated per task

---

## ◉ Key Differences

### Complexity

**MCP:**
- Full protocol specification
- Client/server architecture
- Multiple transport options
- Complex implementation
- Requires server development

**Skills:**
- Markdown file with YAML metadata
- No server needed
- Drop files in directory
- Simple to create
- No programming required (optional scripts)

### Token Efficiency

**MCP:**
```
GitHub MCP Server loaded:
- Repository structure
- All available tools
- Complete API surface
Total: 20,000-50,000 tokens
```

**Skills:**
```
100 Skills metadata loaded:
Total: ~6,500 tokens

2 Skills activated:
Total: ~3,000 tokens per skill = 6,000 tokens

Grand Total: ~12,500 tokens
```

### Setup Complexity

**MCP:**
```python
# Requires server implementation
from mcp import Server, Tool, Resource

server = Server("github")

@server.tool()
async def create_issue(repo: str, title: str, body: str):
    # Implementation required
    ...

@server.resource()
async def get_repo_contents(repo: str):
    # Implementation required
    ...

# Run server on specific transport
server.run(transport="stdio")
```

**Skills:**
```markdown
<!-- Just create a file -->
---
name: my-skill
description: What it does
---

# Instructions

Do this when user asks for that.
```

---

## ◉ When to Use Each

### Use Skills For:

✓ **Repeatable Workflows**
- Document generation
- Code review processes
- Style compliance
- Template application
- Report creation

✓ **Structured Tasks**
- Following specific procedures
- Applying organizational standards
- Consistent formatting
- Multi-step processes

✓ **Knowledge Capture**
- Brand guidelines
- Coding standards
- Business rules
- Best practices

✓ **Token Efficiency**
- Large library of capabilities
- Need to minimize context usage
- Frequent task switching

### Use MCP For:

✓ **External Integrations**
- Database connections
- API access
- Cloud services
- Third-party tools

✓ **Dynamic Data**
- Real-time information
- External data sources
- Live system state
- Changing datasets

✓ **Complex Tools**
- Multi-step external operations
- System integrations
- Service orchestration
- Enterprise systems

✓ **Reusability Across Hosts**
- Same server for multiple applications
- Desktop, CLI, IDEs
- Organization-wide tools

---

## ◉ Using Together

Skills and MCP are **complementary** - use both!

### Pattern: Skill Calls MCP Tools

```markdown
---
name: github-workflow
description: Manage GitHub PRs following team process
---

# GitHub Workflow Skill

## PR Review Process

1. Load PR using GitHub MCP tool: `get_pr_details`
2. Review changes against checklist (below)
3. Post comments using GitHub MCP tool: `create_pr_comment`
4. Approve or request changes: `update_pr_status`

## Review Checklist

- [ ] Code follows style guide
- [ ] Tests included
- [ ] Documentation updated
- [ ] No security issues

## Example

```
User: "Review PR #123"

Claude:
1. Uses GitHub MCP to fetch PR
2. Uses skill checklist to review
3. Uses GitHub MCP to post comments
```
```

**Benefit:** Skill provides structure, MCP provides data and actions

### Pattern: MCP Provides Data, Skill Provides Process

**Scenario:** Financial reporting

**MCP Server:** Database connection
- Tool: `query_sales_data`
- Tool: `get_expenses`
- Tool: `fetch_budget`

**Skill:** Financial report generator
- Format specifications
- Calculation formulas
- Report template
- Compliance rules

**Workflow:**
```
User: "Generate Q3 financial report"

Claude:
1. Activates financial-report skill (process)
2. Calls database MCP tools (data)
3. Follows skill instructions (format)
4. Generates compliant report
```

---

## ◉ Practical Examples

### Example 1: Documentation Writer

**MCP:**
- GitHub server: Read code, get commits
- Jira server: Fetch issue details

**Skill:**
- Documentation style guide
- Template structure
- Writing tone
- Format requirements

**Combined:**
```
User: "Document the authentication module"

Claude:
1. MCP (GitHub): Reads auth module code
2. MCP (Jira): Gets related tickets
3. Skill: Applies doc template and style
4. Result: Well-formatted, compliant documentation
```

### Example 2: Customer Support

**MCP:**
- CRM server: Customer data
- Ticketing server: Issue tracking
- Knowledge base server: Support articles

**Skill:**
- Response templates
- Tone guidelines
- Escalation process
- Privacy compliance

**Combined:**
```
User: "Respond to ticket #789"

Claude:
1. MCP (Ticketing): Gets ticket details
2. MCP (CRM): Loads customer history
3. MCP (KB): Finds relevant articles
4. Skill: Formats professional response
5. Result: Personalized, compliant support response
```

---

## ◉ Architecture Comparison

### MCP Architecture

```
┌─────────────────────┐
│  Claude (Host)      │
│                     │
│  ┌───────────────┐  │
│  │  MCP Client   │  │
│  └───────┬───────┘  │
└──────────┼──────────┘
           │ Transport (stdio/HTTP/SSE)
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────┐
│ GitHub │   │Database│
│  MCP   │   │  MCP   │
│ Server │   │ Server │
└────────┘   └────────┘
```

### Skills Architecture

```
┌─────────────────────────────┐
│  Claude                     │
│                             │
│  Skill Discovery            │
│  ↓                          │
│  Tier 1: Load Metadata      │
│  (~6,500 tokens)            │
│  ↓                          │
│  Match Skills to Task       │
│  ↓                          │
│  Tier 2: Load Instructions  │
│  (~3,000 tokens per skill)  │
│  ↓                          │
│  Tier 3: Load Resources     │
│  (on demand)                │
│                             │
│  Execute Task               │
└─────────────────────────────┘

Skills stored locally:
~/.claude/skills/skill-1/
~/.claude/skills/skill-2/
.claude/skills/project-skill/
```

---

## ◉ Decision Matrix

| Requirement | Recommendation |
|-------------|----------------|
| Need external data | **MCP** |
| Following internal process | **Skills** |
| API integration | **MCP** |
| Template application | **Skills** |
| Real-time information | **MCP** |
| Style compliance | **Skills** |
| Database access | **MCP** |
| Document generation | **Skills** |
| Multi-tool orchestration | **MCP** |
| Repeatable workflow | **Skills** |
| Organization standards | **Skills** |
| External service calls | **MCP** |
| **Both needed** | **Use Together!** |

---

## ◉ Cost Comparison

### Token Costs

**MCP Approach:**
```
GitHub MCP loaded:         30,000 tokens
Database MCP loaded:       20,000 tokens
Calendar MCP loaded:       15,000 tokens
────────────────────────────────────────
Total overhead:            65,000 tokens
Available for work:       135,000 tokens (67.5%)
```

**Skills Approach:**
```
100 skills metadata:        6,500 tokens
2 active skills:            6,000 tokens
────────────────────────────────────────
Total overhead:            12,500 tokens
Available for work:       187,500 tokens (93.75%)
```

**Combined Approach:**
```
1 MCP server (targeted):   15,000 tokens
100 skills metadata:        6,500 tokens
2 active skills:            6,000 tokens
────────────────────────────────────────
Total overhead:            27,500 tokens
Available for work:       172,500 tokens (86.25%)
```

### Development Costs

**MCP:**
- Server development: Days-weeks
- Protocol learning curve
- Testing complexity
- Deployment infrastructure

**Skills:**
- Skill creation: Minutes-hours
- Simple Markdown format
- Easy testing
- Drop-in deployment

---

## ◉ Future Outlook

Both technologies will likely evolve:

**MCP Evolution:**
- Better token efficiency
- Simplified server creation
- More pre-built servers
- Enhanced composability

**Skills Evolution:**
- Richer metadata
- Better discovery
- Marketplace growth
- Platform integration

**Convergence:**
- Skills may reference MCP servers
- MCP servers may include skill definitions
- Hybrid approaches
- Unified tooling

---

## ◉ Summary

**Use Skills when:**
- Need repeatable workflows
- Want token efficiency
- Following internal standards
- Require simple setup
- Generating documents

**Use MCP when:**
- Integrating external services
- Accessing live data
- Building reusable integrations
- Connecting enterprise systems
- Need cross-platform tools

**Use Both when:**
- Process (Skills) + Data (MCP)
- Structure (Skills) + Integration (MCP)
- Standards (Skills) + External Tools (MCP)

**Remember:** They're complementary, not competing!

---

**Navigation:**
- [← Back to Examples](08-Example-Skills-Catalog.md)
- [Next: Limitations & Constraints →](10-Limitations-Constraints.md)

#fin
