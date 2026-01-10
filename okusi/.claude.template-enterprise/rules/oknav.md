# Multi-Server Navigation (oknav)

Use `ok1`, `ok2`, `ok3`, etc. to execute commands on remote Okusi servers. These are symlinks to `ok_master` that resolve the target via `hosts.conf`.

## Single-Server Commands

```bash
ok1 uptime               # Run 'uptime' on ok1 server
ok1                      # Interactive shell on ok1
ok1 -r systemctl status  # Connect as root
ok1 -d                   # Preserve current working directory
ok1 -rd                  # Root shell, same directory
```

## Available Hosts

| Alias | Server | Notes |
|-------|--------|-------|
| `ok0` | okusi0 | Primary |
| `ok1` | okusi1 | — |
| `ok2` | okusi2 | — |
| `ok3` | okusi3 | — |
| `okdev` | okusi | Dev (local-only) |
| `ok-batam` | okusi0-batam | Branch office |

Run `oknav list` to see all installed launchers.

## Multi-Server Commands (oknav)

```bash
oknav uptime             # Sequential on all oknav-enabled servers
oknav -p 'df -h'         # Parallel execution
oknav -x ok0 uptime      # Exclude ok0 from this run
```

▲ **Important**: Do NOT use `ok_master` directly—always use the hostname symlink (`ok1`, `ok2`, etc.).
