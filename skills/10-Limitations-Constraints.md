# Claude Skills - Limitations and Constraints

**Last Updated:** October 19, 2025

---

## ◉ Context Window Constraints

### Token Limits by Model

| Model | Context Window | Practical Limit with Skills |
|-------|----------------|----------------------------|
| Claude 3 Haiku | 200,000 tokens | ~180,000 usable |
| Claude 3 Sonnet | 200,000 tokens | ~180,000 usable |
| Claude 3.5 Sonnet | 200,000 tokens | ~180,000 usable |
| Claude 3 Opus | 200,000 tokens | ~180,000 usable |
| Claude Sonnet 4.5 (API) | 1,000,000 tokens | ~980,000 usable |

### Skill Token Overhead

**Typical Usage:**
```
100 skills installed:
- Tier 1 metadata: ~6,500 tokens
- Tier 2 (2 active): ~6,000 tokens
- Tier 3 (resources): ~5,000 tokens
───────────────────────────────────────
Total overhead: ~17,500 tokens
Remaining: ~182,500 tokens (91.25%)
```

**Heavy Usage:**
```
500 skills installed:
- Tier 1 metadata: ~32,500 tokens
- Tier 2 (3 active): ~9,000 tokens
- Tier 3 (resources): ~15,000 tokens
───────────────────────────────────────
Total overhead: ~56,500 tokens
Remaining: ~143,500 tokens (71.75%)
```

---

## ◉ Field Constraints

### YAML Frontmatter Limits

| Field | Maximum | Recommended | Notes |
|-------|---------|-------------|-------|
| `name` | 64 characters | 20-30 chars | Must match directory name |
| `description` | 1,024 characters | 200-500 chars | Include triggers |
| SKILL.md (Tier 2) | No hard limit | <5,000 tokens | ~3,750 words |
| Resources (Tier 3) | No hard limit | As needed | Loaded on demand |

### Skill Count Limits

**API:**
- Maximum 8 skills per request
- No limit on total skills in account
- Version control supported

**Claude Code:**
- No hard limit on installed skills
- Practical limit: ~500-1000 skills
- Performance degrades with excessive skills

**Claude.ai:**
- Skill limits by plan (specific numbers not published)
- Enterprise plans: Higher limits

---

## ◉ API Rate Limits

### Messages API Limits

| Plan | Requests/Min | Input Tokens/Min | Output Tokens/Min |
|------|--------------|------------------|-------------------|
| Free | N/A | N/A | N/A |
| Pro | Varies | Varies | Varies |
| Team | Higher | Higher | Higher |
| Enterprise | Custom | Custom | Custom |

**Note:** Specific limits vary by model and plan tier. Check official documentation for current rates.

### Skill-Specific Considerations

**Skills don't have separate rate limits**, but:
- Code execution has timeout limits (~10 minutes max)
- Large resource loading counts toward token limits
- Script execution time limits apply

---

## ◉ Platform Availability

### Features by Platform

| Feature | Claude.ai | Claude Code | API |
|---------|-----------|-------------|-----|
| **Personal Skills** | ✓ Cloud | ✓ ~/.claude/skills | ✓ Upload |
| **Project Skills** | ✓ Team | ✓ .claude/skills | ✓ Container param |
| **Plugin Marketplace** | ✗ | ✓ | ✗ |
| **Script Execution** | ✓ | ✓ | ✓ |
| **allowed-tools** | ✗ | ✓ | ✗ |
| **Progressive Disclosure** | ✓ | ✓ | ✓ |
| **Version Control** | Limited | ✓ Git | ✓ API |

### Plan Availability

| Plan | Claude.ai | Claude Code | API |
|------|-----------|-------------|-----|
| Free | ✗ | ✗ | ✗ |
| Pro | ✓ | ✓ Beta | ✓ |
| Max | ✓ | ✓ Beta | ✓ |
| Team | ✓ | ✓ Beta | ✓ |
| Enterprise | ✓ | ✓ Beta | ✓ |

---

## ◉ Code Execution Constraints

### Script Limitations

**Timeout:**
- Maximum execution time: ~10 minutes
- Recommended: Keep scripts under 1 minute
- Long-running tasks may fail

**Environment:**
- Isolated container
- Limited network access
- Temporary filesystem
- No persistent storage

**Available Languages:**
- Python 3.x (pre-installed)
- Node.js (pre-installed)
- Bash/shell scripts
- Other languages: May require installation

**Resource Limits:**
- CPU: Shared, throttled
- Memory: Limited (specific limits not published)
- Disk: Temporary only
- Network: Restricted or unavailable

### Dependencies

**Pre-installed:**
```python
# Available by default
import json
import csv
import re
import os
import sys
```

**Custom Dependencies:**
```python
# May not be available - check before using
import pandas  # Not guaranteed
import requests  # May be blocked
import numpy  # Not guaranteed
```

**Workaround:**
Include dependency installation in script:
```bash
#!/bin/bash
pip install --quiet pandas
python script.py
```

---

## ◉ File and Resource Limits

### File Sizes

**SKILL.md:**
- No hard limit
- Recommended: <100KB
- Tier 2 loads full content
- Keep under 5,000 tokens for efficiency

**Resource Files:**
- Individual files: No published limit
- Recommended: <10MB per file
- Large files slow loading
- Use references to external storage for very large files

**Total Skill Size:**
- No hard limit
- Recommended: <50MB per skill
- Impacts loading time
- Use external storage for large datasets

### File Types

**Supported:**
- Text files (.md, .txt, .json, .csv, .xml)
- Images (.png, .jpg, .svg, .gif)
- Documents (.pdf, .docx, .xlsx, .pptx)
- Code (.py, .js, .sh, etc.)

**Limited Support:**
- Binary files (may not load in context)
- Compressed archives (.zip, .tar.gz)
- Very large media files

---

## ◉ Known Issues and Workarounds

### Issue 1: Skills Not Loading

**Symptoms:**
- Skill in directory but not recognized
- No activation despite triggers

**Causes:**
- Invalid YAML syntax
- Name mismatch with directory
- File permissions

**Workarounds:**
```bash
# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('SKILL.md'))"

# Check permissions
chmod 644 SKILL.md

# Restart Claude Code
```

### Issue 2: Resource Loading Failure

**Symptoms:**
- Resources not found
- Relative path errors

**Causes:**
- Incorrect path format
- Absolute vs relative paths
- File moved/renamed

**Workarounds:**
```markdown
# ✗ Absolute path (breaks portability)
/Users/me/.claude/skills/my-skill/resources/file.md

# ✓ Relative path
resources/file.md

# ✓ From skill root
./resources/file.md
```

### Issue 3: Script Execution Timeout

**Symptoms:**
- Script runs but no output
- Timeout errors

**Causes:**
- Long-running operations
- Infinite loops
- Network calls hanging

**Workarounds:**
```python
# Add timeouts
import signal

def timeout_handler(signum, frame):
    raise TimeoutError("Script timeout")

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(60)  # 60 second timeout

try:
    # Your code here
    result = long_running_operation()
except TimeoutError:
    print("Operation timed out", file=sys.stderr)
    sys.exit(1)
finally:
    signal.alarm(0)  # Cancel alarm
```

### Issue 4: Token Limit Exceeded

**Symptoms:**
- Skill cuts off mid-instruction
- Resources not loading
- Partial responses

**Causes:**
- Too many skills activated
- Large resource files
- Long conversation history

**Workarounds:**
```markdown
# Reduce Tier 2 size
## Details
For complete information, see `resources/details.md`

Summary:
- Key point 1
- Key point 2
- Key point 3

# Use external references
Full specification: https://company.com/docs/spec.pdf
(Link instead of embedding content)
```

---

## ◉ Security Limitations

### Execution Sandbox

**Can Do:**
- Read/write temp files
- Execute safe scripts
- Process data

**Cannot Do:**
- Access internet (limited/blocked)
- Modify system files
- Persist data across sessions
- Access user's filesystem outside temp

### Data Privacy

**Considerations:**
- Skills uploaded to API stored on Anthropic servers
- Script execution happens in Anthropic infrastructure
- Local skills (Claude Code) stay local
- Review privacy policy for data handling

**Recommendations:**
- Don't include sensitive data in skills
- Use environment variables for secrets
- Audit third-party skills before installing
- Consider data residency requirements

---

## ◉ Performance Considerations

### Skill Loading Time

**Fast (<100ms):**
- Small skills (<1KB)
- Minimal resources
- Simple instructions

**Moderate (100-500ms):**
- Average skills (5-20KB)
- Few resources
- Standard complexity

**Slow (>500ms):**
- Large skills (>50KB)
- Many resources
- Complex scripts

### Discovery Performance

**Number of Skills vs Discovery Time:**
```
10 skills: ~10ms
100 skills: ~50ms
500 skills: ~200ms
1000 skills: ~500ms
```

**Recommendation:** Keep under 500 skills for optimal performance.

---

## ◉ Compatibility Issues

### Cross-Platform Differences

**Skill Features:**
- `allowed-tools`: Only Claude Code
- Plugin marketplace: Only Claude Code
- Team sharing: Only Claude.ai Team/Enterprise
- Version control: Best in API

**Script Compatibility:**
```bash
# ✗ Platform-specific
C:\Users\me\script.bat  # Windows only

# ✓ Cross-platform
python scripts/process.py
```

### Model Compatibility

**All Models Support:**
- Basic skill loading
- Tier 1/2/3 architecture
- Script execution

**Model Differences:**
- Response quality varies
- Some models better at specific tasks
- Test skills across models

---

## ◉ Workaround Strategies

### For Token Limits

1. **Aggressive summarization** in Tier 2
2. **Reference external docs** instead of embedding
3. **Use scripts** for algorithms
4. **Split large skills** into focused smaller skills

### For Script Limitations

1. **Keep scripts simple** and fast
2. **Add timeouts** to prevent hangs
3. **Handle errors gracefully**
4. **Test offline** before deploying

### For Resource Limits

1. **External storage** for large files
2. **Lazy loading** via progressive disclosure
3. **Compressed formats** where possible
4. **Link to online resources** for very large datasets

---

## ◉ Future Improvements Expected

### Likely Enhancements

**Short Term (Weeks-Months):**
- Better error messages
- Improved discovery
- More examples
- Performance optimizations

**Medium Term (Months-Quarters):**
- Higher token limits
- Better resource handling
- Enhanced security
- Platform feature parity

**Long Term (Quarters-Years):**
- Skill marketplace
- Advanced composition
- Collaborative editing
- Enterprise features

---

## ◉ Support and Documentation

### Getting Help

**Official Resources:**
- Documentation: https://docs.claude.com
- Help Center: https://support.claude.com
- API Reference: https://docs.claude.com/en/api

**Community:**
- GitHub Issues: https://github.com/anthropics/skills/issues
- Hacker News discussions
- Reddit: r/ClaudeAI

**Enterprise Support:**
- Dedicated support channels
- SLA guarantees
- Priority bug fixes

---

## ◉ Summary

**Key Limitations:**

| Category | Primary Constraint |
|----------|-------------------|
| **Token Limits** | 200K context (1M for Sonnet 4.5 API) |
| **Field Sizes** | name: 64 chars, description: 1024 chars |
| **API Limits** | 8 skills per request |
| **Execution** | ~10 minute script timeout |
| **Availability** | Pro+ plans only |

**Best Practices:**
- Keep skills focused and concise
- Use progressive disclosure
- Test thoroughly before deploying
- Monitor token usage
- Have fallback strategies

**Remember:** These are current limitations as of October 2025 - expect improvements over time!

---

**Navigation:**
- [← Back to Skills vs MCP](09-Skills-vs-MCP.md)
- [Next: Quick Reference →](11-Quick-Reference.md)

#fin
