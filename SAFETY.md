# Safety

This repo is **public**. Nothing secret goes in it, ever.

## Never commit

- `~/.ssh/` (keys, known_hosts)
- `~/.gnupg/`
- `~/.config/gh/hosts.yml` (GitHub token)
- `~/.docker/config.json`
- `~/.pi/agent/auth.json`, `~/.pi/telegram/settings.json`
- `~/.config/opencode/` (service.json, node_modules)
- `~/.claude*`, `~/.codex/`
- `~/.config/gcloud/`, `~/.aws/`, `~/.kube/`
- VS Code `globalStorage/`, `History/`, `workspaceStorage/`
- shell history (`.zsh_history`, `.bash_history`)
- browser profiles
- anything matching `*.env`, `*.pem`, `*.key`
- `~/.secrets.zsh` (live) — only `zsh/secrets.example.zsh` is tracked

## Secrets on this machine (names only)

| Where | Name |
|---|---|
| `~/.secrets.zsh` | `DISCORD_WEBHOOK_URL` |
| `~/.secrets.zsh` | `DISCORD_NOTIFY_ROLE_ID` |
| `~/.secrets.zsh` | `CH_HOST` |
| `~/.secrets.zsh` | `CH_PW` |
| `~/.ssh/` | `id_ed25519`, `google_compute_engine` |
| `~/.config/gh/hosts.yml` | GitHub token |
| `~/.docker/config.json` | registry auth |
| `~/.pi/agent/auth.json` | agent provider keys |
| `~/.pi/telegram/settings.json` | bot token, allowed users |
| `~/.config/opencode/service.json` | service keys |
| `~/.config/gcloud/` | GCP credentials |

## Rotate (manual, after any exposure)

1. Discord: Channel Settings -> Integrations -> Webhooks -> delete the old
   webhook, create a new one, update `~/.secrets.zsh`.
2. ClickHouse: rotate the user password in the ClickHouse Cloud console,
   update `CH_PW` in `~/.secrets.zsh`.
3. GitHub: `gh auth refresh -h github.com`.
4. SSH/GPG: only if a key file itself was exposed. Generate a new key,
   replace the public key wherever it is authorized, then revoke the old one.

Never paste values into issues, logs, screenshots, or commits.

## Secret layout

`~/.zshrc` (tracked) does:

```sh
[ -f "$HOME/.secrets.zsh" ] && source "$HOME/.secrets.zsh"
```

`~/.secrets.zsh` is local-only and never in git.
`zsh/secrets.example.zsh` is the tracked template.

## Pre-push scan

```sh
git grep -nEI '(ghp_|github_pat_|AKIA|sk-[A-Za-z0-9]{20,}|xox[baprs]-|discord(app)?\.com/api/webhooks|hooks\.slack)' || true
```

Optional: `gitleaks detect --no-banner`.

## Encrypted offline backup

```sh
tar czf - \
  ~/.ssh ~/.gnupg ~/.secrets.zsh \
  ~/.config/gh ~/.config/gcloud ~/.pi ~/.config/opencode \
  | gpg -c -o ~/secrets-backup-$(date +%F).tar.gz.gpg
```

Store it on external media. Never in git, never in a cloud folder that is shared.

## Restore checklist

- [ ] Clone repo, run `scripts/install.sh`
- [ ] Decrypt and unpack `secrets-backup-*.gpg` into `$HOME`
- [ ] `gh auth login`
- [ ] `gcloud auth login` (if needed)
- [ ] Re-add SSH key to GitHub / servers
- [ ] Check `~/.secrets.zsh` is readable only by you (`chmod 600`)
