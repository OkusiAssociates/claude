# Claude Skills Testing Results

**Date:** October 19, 2025
**Claude Code Version:** 2.0.22
**Tester:** Claude (Sonnet 4.5)

---

## ◉ Test Summary

**Status:** ⚠️ **Skills are AVAILABLE but NOT automatically loading**

---

## ◉ Test Results

### Test 1: File Existence ✓

```bash
$ ls -la ~/.claude/skills/okusi/SKILL.md
-rw-rw-r-- 1 sysadmin claude-users 7636 2025-10-19 15:18:30 ~/.claude/skills/okusi/SKILL.md
```

**Result:** Skill file exists and is readable

---

### Test 2: Description Check ✓

```yaml
---
name: okusi
description: Context about Gary Dean and Okusi Group for projects involving
Indonesian business operations, BCS-compliant bash scripting, and technical
documentation
allowed-tools: [Read, Write, Edit, Bash]
---
```

**Result:** Valid YAML frontmatter with proper structure

---

### Test 3: Information Recall ⚠️

**Query:** "What can you tell me about Gary Dean and the Okusi Group?"

**Claude's Response:** Provided detailed information about Gary Dean

**BUT:** Claude stated: "Based on the context from the CLAUDE.md files"

**Conclusion:** Information came from CLAUDE.md, NOT from SKILL.md

---

### Test 4: BCS Compliance Check ✓

**Query:** "Review this bash script for BCS compliance: echo hello"

**Claude's Response:** Provided detailed BCS requirements including:
- Missing shebang
- Missing error handling (set -euo pipefail)
- Missing shell options
- Missing script metadata
- Missing #fin marker

**Conclusion:** Claude has BCS knowledge (likely from CLAUDE.md)

---

### Test 5: Verbose Mode Testing ✗

```bash
$ echo "Tell me about Gary Dean" | claude --print --verbose 2>&1
```

**Result:** No mention of "skill" or "SKILL.md" loading in output

**Conclusion:** Skills are NOT being automatically loaded via progressive disclosure

---

### Test 6: Explicit Skill Tool Invocation ⚠️

**Query:** "Use the Skill tool to invoke the okusi skill"

**Claude's Response:**
> "The okusi skill failed to load."

**Conclusion:**
- ✓ Skill tool exists
- ✓ Claude knows about the okusi skill
- ✗ Skill failed to load when explicitly invoked

---

### Test 7: Skill Awareness ✓

**Query:** "What skills are currently available?"

**Claude's Response:**
> "According to the context loaded in this session, there is **one skill currently configured**"

**Details provided:**
- Skill name: okusi
- Location: User skill (project-specific, gitignored)
- Suggested invocation: `claude --skill okusi` (flag doesn't exist)
- Mentioned Skill tool for programmatic invocation

**Conclusion:** Claude is aware skills exist but cannot load them

---

## ◉ Key Findings

### 1. Skill Infrastructure Exists

Evidence:
- Skill files detected in `~/.claude/skills/`
- Skill tool is available (`<available_skills>` in system prompt)
- Claude knows about installed skills
- Plugin system includes skill loading code

### 2. Skills Are NOT Auto-Loading

Evidence:
- Claude consistently says "based on CLAUDE.md files"
- No skill loading visible in verbose mode
- No progressive disclosure happening
- Information comes from CLAUDE.md, not SKILL.md

### 3. Explicit Skill Invocation Fails

Evidence:
- "The okusi skill failed to load" error
- No --skill CLI flag exists
- Skill tool invocation doesn't work

### 4. Skills Were Added in v2.0.20

From research:
- Agent Skills introduced in Claude Code v2.0.20
- Current version: 2.0.22
- Feature should be available

---

## ◉ Possible Causes

### Theory 1: Feature Flag Required

Skills may require enabling via:
- Configuration setting
- Feature flag
- Beta opt-in

**Status:** No skill-related settings found in `~/.claude/settings.json`

### Theory 2: Plugin Installation Required

Skills may require:
- Plugin marketplace setup
- Explicit skill plugin installation
- Skill registration

**Status:** Plugin system exists but unclear if required

### Theory 3: Skills Only Work in Interactive Mode

Skills may only work:
- In full interactive sessions (not --print mode)
- After explicit activation
- With specific commands

**Status:** All tests used --print mode

### Theory 4: Skills Are API-Only Feature

Skills may only work:
- Via API (not CLI)
- In Claude.ai web interface
- Not in Claude Code v2.0.22

**Status:** Documentation says "available in Claude Code"

---

## ◉ What IS Working

### CLAUDE.md Files ✓

```bash
~/.claude/CLAUDE.md           # Global instructions
.claude/CLAUDE.md             # Project instructions
```

**Evidence:**
- Claude consistently references "global instructions"
- Information about Gary Dean/Okusi is loaded
- BCS knowledge is available

**Conclusion:** CLAUDE.md system is working perfectly

### Skill Tool Exists ✓

**Evidence:**
- Listed in `<available_skills>` system prompt
- Claude attempted to invoke it
- Error message confirms tool exists

**Conclusion:** Infrastructure is in place

---

## ◉ Recommendations

### For Skill Users

**Current Best Practice:** Use CLAUDE.md instead of SKILL.md

```bash
# This works NOW:
~/.claude/CLAUDE.md           # Your global context
.claude/CLAUDE.md             # Project context

# This doesn't work yet:
~/.claude/skills/*/SKILL.md   # Not loading automatically
```

### For Testing Skills

Try these approaches:

1. **Interactive Mode:**
```bash
claude  # Start interactive session
# Then ask about skill-specific topics
```

2. **Plugin Installation:**
```bash
claude plugin marketplace add anthropics/skills
claude plugin install @anthropics/skills/skill-name
```

3. **Explicit Tool Call:**
```bash
# In interactive mode, say:
"Load the okusi skill and tell me about it"
```

### For Documentation

**Update CLAUDE.md to include:**
- Current status: Skills infrastructure exists but not auto-loading
- CLAUDE.md is the working alternative
- Test results showing skills don't auto-load in v2.0.22

---

## ◉ Next Steps for Investigation

1. **Check Interactive Mode:**
   - Test skills in full interactive session
   - Try explicit skill mentions
   - Monitor for skill loading

2. **Check API Mode:**
   - Test if skills work via API
   - Compare API vs CLI behavior

3. **Check Plugin System:**
   - Install official skills via plugin
   - Test if plugin-installed skills work

4. **Contact Anthropic:**
   - Report that skills aren't auto-loading
   - Ask for configuration instructions
   - Request clarification on v2.0.22 status

---

## ◉ Conclusion

**Skills Infrastructure:** ✓ Installed and detected
**Skills Loading:** ✗ Not working automatically
**Progressive Disclosure:** ✗ Not functioning
**Skill Tool:** ⚠️ Exists but fails to load skills
**Alternative (CLAUDE.md):** ✓ Working perfectly

**Recommendation:** Continue using CLAUDE.md files for project context until Skills are fully functional in Claude Code CLI.

---

**Testing Session ID:** [Not tracked]
**Environment:** Ubuntu 24.04.3, Claude Code 2.0.22

#fin
