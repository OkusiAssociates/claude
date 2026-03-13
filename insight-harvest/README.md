# insight-harvest

Extract and categorize `★ Insight` blocks from Claude Code session transcripts into a searchable Markdown archive.

```bash
insight-harvest            # Incremental harvest (skip unchanged files)
insight-harvest --full     # Force re-scan of all transcript files
insight-harvest --stats    # Show category distribution
insight-harvest --search TERM  # Search across harvested insights
```

## How It Works

The script scans `~/.claude/projects/**/*.jsonl` for assistant messages containing `★ Insight` blocks, deduplicates by content hash, categorizes by project directory path (with keyword fallback), and writes indexed Markdown files to `~/.claude/insights/`.

Incremental mode (default) tracks file mtimes in `state.json` to skip already-processed transcripts. Use `--full` to force a complete rescan.

### Categorization

Two-tier strategy:

1. **By CWD** — the session's working directory path is matched against known project patterns (e.g. `*/bash*` → `bash`, `*/yatti*` → `python`)
2. **By content** — if CWD doesn't match, keyword matching on the insight text determines category (e.g. mentions of `shellcheck` → `bash`, `sql` → `mysql`)

### Categories

`bash` `python` `php` `javascript` `git` `mysql` `security` `system` `web` `email` `claude-code` `architecture` `general`

## Output Structure

```
~/.claude/insights/
  index.md                  # Auto-generated master index
  state.json                # Mtime tracking for incremental mode
  bash/
    bash-001.md
    bash-002.md
  python/
    python-001.md
  ...
```

Each insight file contains the extracted text, source metadata (project, session ID, date), and a dedup hash as an HTML comment.

## Options

| Option | Description |
|--------|-------------|
| *(none)* | Incremental harvest (skip unchanged files) |
| `--full` | Force re-scan of all transcript files |
| `--stats` | Show category distribution summary |
| `--search TERM` | Search across harvested insights |
| `--version`, `-V` | Show version |
| `--help`, `-h` | Show usage help |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Missing dependency |
| 22 | Invalid option (EINVAL) |

## Dependencies

`jq`, `md5sum` (coreutils)

## Installation

The `.symlink` file marks `insight-harvest` for symlinking into PATH (e.g. via `symlink`).

#fin
