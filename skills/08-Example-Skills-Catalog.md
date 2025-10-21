# Claude Skills - Example Skills Catalog

**Last Updated:** October 19, 2025
**Source:** anthropics/skills repository

---

## ◉ Official Anthropic Skills

### Document Skills

#### powerpoint
Create professional PowerPoint presentations with formulas and formatting.

**Use Cases:**
- Business presentations
- Pitch decks
- Training materials
- Reports

**Features:**
- Template support
- Formula integration
- Professional formatting
- Chart generation

#### excel-advanced
Generate Excel spreadsheets with advanced formulas, charts, and formatting.

**Use Cases:**
- Financial models
- Data analysis
- Budget tracking
- Forecasting

**Features:**
- Complex formulas
- Pivot tables
- Charts and graphs
- Conditional formatting

#### word
Create Word documents with proper formatting and styles.

**Use Cases:**
- Reports
- Proposals
- Documentation
- Letters

#### pdf
Generate and work with fillable PDF forms and documents.

**Use Cases:**
- Form creation
- PDF generation
- Document conversion

---

### Creative Skills

#### algorithmic-art
Create generative art using p5.js with seeded randomness, flow fields, and particle systems.

**Repository:** anthropics/skills/algorithmic-art

**Use Cases:**
- Generative art
- Creative coding
- Visual experiments
- Interactive graphics

**Features:**
- p5.js integration
- Seeded randomness
- Flow fields
- Particle systems

**Example:**
```
User: "Create generative art with flow fields"
→ Produces unique artwork with specified parameters
```

#### canvas-design
Design beautiful visual art in .png and .pdf formats using design philosophies.

**Use Cases:**
- Marketing graphics
- Social media images
- Poster design
- Visual branding

#### slack-gif-creator
Create animated GIFs optimized for Slack's size constraints.

**Use Cases:**
- Team communication
- Emoji alternatives
- Celebration animations
- Status indicators

---

### Development Skills

#### artifacts-builder
Build complex claude.ai HTML artifacts using React, Tailwind CSS, and shadcn/ui components.

**Repository:** anthropics/skills/artifacts-builder

**Use Cases:**
- Interactive demos
- Web components
- Prototypes
- Educational content

**Features:**
- React components
- Tailwind CSS
- shadcn/ui integration
- Responsive design

#### mcp-server
Guide for creating high-quality MCP servers to integrate external APIs and services.

**Repository:** anthropics/skills/mcp-server

**Use Cases:**
- API integration
- External service connection
- Custom protocol implementation

**Features:**
- MCP protocol compliance
- Best practices
- Example patterns
- Testing guidelines

#### webapp-testing
Test local web applications using Playwright for UI verification and debugging.

**Repository:** anthropics/skills/webapp-testing

**Use Cases:**
- E2E testing
- UI verification
- Regression testing
- Debugging

**Features:**
- Playwright integration
- Screenshot comparison
- Interactive debugging
- Test automation

---

### Brand and Communication

#### brand-guidelines
Apply Anthropic's official brand colors and typography to artifacts.

**Use Cases:**
- Branded content
- Marketing materials
- Presentations
- Documents

**Features:**
- Color palette enforcement
- Typography rules
- Logo usage guidelines
- Template library

#### internal-comms
Write internal communications like status reports, newsletters, and FAQs.

**Repository:** anthropics/skills/internal-comms

**Use Cases:**
- Status updates
- Team newsletters
- FAQ documentation
- Announcements

**Features:**
- Template library
- Tone guidelines
- Format standards
- Example collection

**Example Templates:**
- Status reports
- Newsletter articles
- FAQ answers
- Team updates
- Project summaries

---

## ◉ Community Skills

### Data and Analysis

#### financial-modeling
Create financial models with forecasting and scenario analysis.

**Use Cases:**
- Revenue projections
- Budget planning
- Investment analysis
- Scenario modeling

#### data-validation
Validate CSV/JSON data against schemas and business rules.

**Use Cases:**
- Data imports
- Quality assurance
- Compliance checking
- ETL processes

### Code Quality

#### code-reviewer
Review code for quality, security, and best practices.

**Use Cases:**
- Pull request reviews
- Code audits
- Security scanning
- Style enforcement

#### test-generator
Generate unit tests for various programming languages.

**Use Cases:**
- Test automation
- Coverage improvement
- TDD support
- Regression prevention

### Documentation

#### api-documenter
Generate API documentation from code and specifications.

**Use Cases:**
- API reference
- Integration guides
- OpenAPI specs
- SDK documentation

#### readme-generator
Create comprehensive README files for projects.

**Use Cases:**
- Open source projects
- Internal tools
- Documentation
- Onboarding

---

## ◉ Installation

### From anthropics/skills Repository

```bash
# Clone repository
git clone https://github.com/anthropics/skills.git

# Copy specific skill
cp -r skills/algorithmic-art ~/.claude/skills/

# Or copy all
cp -r skills/* ~/.claude/skills/
```

### Via Plugin Marketplace

```bash
# Add marketplace
/plugin marketplace add anthropics/skills

# Install skill
/plugin install @anthropics/skills/algorithmic-art
```

---

## ◉ Creating Custom Skills

### Based on Examples

1. **Study example skills** from anthropics/skills
2. **Identify pattern** that matches your need
3. **Copy and modify** for your use case
4. **Test thoroughly**
5. **Document well**

### Example: Custom Brand Guidelines

```yaml
---
name: my-company-brand
description: Apply MyCompany brand standards including colors (#FF5733, #333333), fonts (Inter, Roboto), and logo usage
license: Proprietary
---

# MyCompany Brand Guidelines

[Customize based on anthropics/skills/brand-guidelines]

## Colors
- Primary: #FF5733
- Secondary: #333333

## Fonts
- Headers: Inter
- Body: Roboto

## Logo
See `resources/logos/` for approved versions.
```

---

## ◉ Skill Combinations

Skills work together automatically:

**Example 1: Branded Financial Presentation**
```
Skills activated:
- brand-guidelines (ensures brand compliance)
- powerpoint (creates presentation)
- financial-modeling (provides financial content)

Result: Branded PowerPoint with financial models
```

**Example 2: Tested Web Application**
```
Skills activated:
- artifacts-builder (creates app)
- webapp-testing (tests functionality)
- code-reviewer (checks quality)

Result: Tested, quality-assured web application
```

**Example 3: Documented API**
```
Skills activated:
- mcp-server (creates API integration)
- api-documenter (generates docs)
- code-reviewer (ensures quality)

Result: Well-documented, high-quality API integration
```

---

## ◉ Skill Development Patterns

### Pattern 1: Template-Based

**Example:** email-templates, document-generator

Structure:
```
skill-name/
├── SKILL.md
└── resources/
    └── templates/
        ├── template1.md
        ├── template2.md
        └── template3.md
```

### Pattern 2: Script-Driven

**Example:** data-validator, test-generator

Structure:
```
skill-name/
├── SKILL.md
└── scripts/
    ├── validate.py
    ├── process.py
    └── report.py
```

### Pattern 3: Reference-Heavy

**Example:** brand-guidelines, coding-standards

Structure:
```
skill-name/
├── SKILL.md
└── resources/
    ├── colors.md
    ├── typography.md
    ├── layouts.md
    └── examples/
```

---

## ◉ Contributing

### To anthropics/skills

1. Fork repository
2. Create skill following patterns
3. Test thoroughly
4. Submit pull request
5. Respond to review feedback

### Guidelines

- Follow existing patterns
- Include comprehensive examples
- Document thoroughly
- Test across platforms
- Provide clear description

---

**Navigation:**
- [← Back to Security](07-Security-Permissions.md)
- [Next: Skills vs MCP →](09-Skills-vs-MCP.md)

#fin
