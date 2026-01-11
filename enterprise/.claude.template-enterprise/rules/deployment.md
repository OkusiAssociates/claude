# Deployment (push-to-okusi)

Production servers (ok1, ok2, ok3) do **not** use git. Deploy using `push-to-okusi`:

```bash
# Dry run (default) - preview changes
push-to-okusi 1 2 3

# Actual sync to all production servers
push-to-okusi -N 1 2 3

# Sync with .venv directory included
push-to-okusi -NV 1

# Sync and delete extraneous files on destination
push-to-okusi -Nd 2
```

## Options

| Option | Description |
|--------|-------------|
| `-n, --dry-run` | Trial run, no changes (default) |
| `-N, --not-dry-run` | Execute actual sync |
| `-d, --delete` | Delete extraneous files from destination |
| `-x, --exclude PATH` | Add additional exclude pattern |
| `-V, --venv` | Include .venv directory in sync |

## Server Numbers

| Number | Server |
|--------|--------|
| 0 | ok0 (Primary) |
| 1 | ok1 (Production) |
| 2 | ok2 (Production) |
| 3 | ok3 (Production) |

Only runs from dev machine (hostname `okusi`). Uses rsync to sync current directory.
