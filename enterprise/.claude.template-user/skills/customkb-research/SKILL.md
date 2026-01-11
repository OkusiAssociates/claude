---
name: customkb-research
description: Deep research across specialized knowledgebases using vector search. Use for comprehensive topic investigation across Indonesian business, law, anthropology, philosophy, and technical domains.
allowed-tools: mcp__customkb__*
metadata:
  version: "1.0.0"
  author: "Okusi"
---

# CustomKB Deep Research Skill

Conduct thorough research across specialized knowledge domains using semantic vector search with hybrid BM25 ranking.

## Available Knowledgebases

| KB | Domain | Best For |
|----|--------|----------|
| `appliedanthropology` | Anthropology, evolution, dharma | Human evolution, cultural development, secular dharma |
| `jakartapost` | News archive 1994-2005 | Indonesian political/social history, reform era |
| `okusiassociates` | Corporate services | PMA company setup, business licensing, compliance |
| `okusimail` | Business correspondence | Inquiry patterns, client communication |
| `okusiresearch` | Investment research | FDI research, corporate law, taxation |
| `ollama` | AI systems | Ollama configuration, model management |
| `openai-docs` | OpenAI documentation | API usage, models, integration |
| `peraturan` | Indonesian law | Laws, regulations, legal compliance |
| `prosocial` | Psychology-philosophy | Human motivation, behavior, ethics |
| `seculardharma` | Secular dharma | Ethical living, philosophy, impermanence |
| `smi` | SMI domain | Specialized SMI research |
| `uv` | Technical | Full-stack development, AI systems |
| `wayang` | Indonesian culture | Wayang, traditional arts, cultural anthropology |

## Research Workflow

1. **Identify Domain(s)** - Select relevant KB(s) based on topic
2. **Initial Search** - Broad query to understand scope
3. **Refine** - Targeted follow-up queries based on findings
4. **Cross-Reference** - Query related KBs for completeness
5. **Synthesize** - Combine findings with source citations

## Domain Groupings

### Indonesian Business & Law
- `okusiassociates` + `okusiresearch` - Company setup, corporate services
- `peraturan` - Legal requirements, regulations
- `jakartapost` - Historical business/political context

### Philosophy & Anthropology
- `appliedanthropology` - Human evolution, cultural development
- `seculardharma` - Ethics, dharma interpretations
- `prosocial` - Psychology, human motivation

### Technical
- `ollama` - Ollama/AI systems
- `openai-docs` - OpenAI API
- `uv` - Programming, systems engineering

### Indonesian Culture
- `wayang` - Traditional arts, puppet theater
- `jakartapost` - Cultural context, history

## Best Practices

- **Start broad** - Initial query to map the domain
- **Use Indonesian terms** for `peraturan` (e.g., "PPh badan", "KITAS")
- **Cross-reference** business queries with `peraturan` for legal backing
- **Check historical context** in `jakartapost` for political topics
- **Cite sources** - Results include document metadata

## Example Research Sessions

### Topic: "PMA company tax obligations in Indonesia"

1. `search_okusiassociates("PMA tax obligations corporate")`
2. `search_peraturan("PPh badan perusahaan asing")`
3. `search_okusiresearch("tax compliance foreign investment")`
4. Synthesize with regulation citations

### Topic: "Evolution of ethical behavior in humans"

1. `search_appliedanthropology("evolution ethics morality")`
2. `search_prosocial("human cooperation altruism")`
3. `search_seculardharma("ethical living evolution")`
4. Synthesize cross-disciplinary findings

### Topic: "Indonesian political reform 1998-2000"

1. `search_jakartapost("reformasi 1998 Suharto")`
2. `search_jakartapost("democracy transition Indonesia")`
3. `search_peraturan("undang-undang reformasi 1998")`
4. Historical narrative with legal context

## Tool Reference

All search tools accept:
- `query` (required): Search query string
- `top_k` (optional, default 50): Number of results
- `output_format` (optional, default "markdown"): xml, json, markdown, plain

Utility tools:
- `list_knowledgebases()` - List all available KBs
- `get_kb_info(knowledgebase)` - Detailed info about a KB
