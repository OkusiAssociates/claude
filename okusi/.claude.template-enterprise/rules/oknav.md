# Server Navigation

Use `ok_master` symlinks to navigate between Okusi servers. Each symlink resolves via `hosts.conf`.

## Available Servers

| Alias      | Server | Use      | Notes
|------------|--------|----------|-----------------------
| `okdev`    | okusi  | dev      | local only dev machine
| `ok0`      | okusi0 | intranet |
| `ok1`      | okusi1 | mail     |
| `ok2`      | okusi2 | backup   | may require `sudo ok2`
| `ok3`      | okusi3 | web      |
| `ok-batam` | okusi0-batam | branch intranet | may require `sudo ok0-batam`

Run `oknav list` to see all installed launchers.

Note that these same utilities are available on every server.

## Single-Server Commands (ok_master)

```bash
ok1 uptime                # Run command on ok1
ok1                       # Interactive shell on ok1
ok1 -r systemctl status   # Connect as root
ok1 -d                    # Preserve current working directory
ok1 -rd                   # Root shell, same directory
sudo ok2 yatti-api status # ok2 requires sudo
```

## Multi-Server Commands (oknav)

```bash
oknav uptime              # Sequential on all oknav-enabled servers
oknav -p 'df -h'          # Parallel execution
oknav -x ok0 uptime       # Exclude ok0 from this run
oknav list                # List installed host symlinks
```

▲ **Important**: Do NOT use `ok_master` directly—always use the hostname symlink (`ok1`, `ok2`, etc.).

# Deployment

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

## push-to-okusi Options

| Option | Description |
|--------|-------------|
| `-n, --dry-run` | Trial run, no changes (default) |
| `-N, --not-dry-run` | Execute actual sync |
| `-d, --delete` | Delete extraneous files from destination |
| `-x, --exclude PATH` | Add additional exclude pattern |
| `-V, --venv` | Include .venv directory in sync |

