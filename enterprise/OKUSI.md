# Okusi Network Deployment

Deployment status and sync commands for Okusi network servers.

## Servers Deployed

| Server | Claude | uv | MCP | Status |
|--------|--------|-----|-----|--------|
| ok0 (okusi) | latest | 0.9.x | customkb | ✓ |
| ok1 (okusi1) | latest | 0.9.x | customkb | ✓ |
| okusi2 | latest | 0.9.x | customkb | ✓ |
| okusi3 | latest | 0.9.x | customkb | ✓ |
| ok0-batam | latest | 0.9.x | customkb | ✓ |

## Sync Commands

### Sync enterprise scripts to all servers

```bash
for server in ok0 ok1 okusi2 okusi3; do
  rsync -av /ai/scripts/claude/enterprise/ "$server:/ai/scripts/claude/enterprise/"
done
```

### Deploy to new server

```bash
# Sync scripts
rsync -av /ai/scripts/claude/enterprise/ SERVER:/ai/scripts/claude/enterprise/

# Run setup
ssh SERVER 'sudo /ai/scripts/claude/enterprise/claude.setup-machine'
```

### Sync enterprise config to production

```bash
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi1:/etc/claude-code/
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi2:/etc/claude-code/
sudo rsync -av --rsync-path="sudo rsync" /etc/claude-code/ okusi3:/etc/claude-code/
```

---

**Last Updated:** 2026-01-11

#fin
