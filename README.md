# fedora

Fedora 44 workstation setup. Public repo: no secrets, ever (see [SAFETY.md](SAFETY.md)).

## Fresh machine

```sh
sudo dnf install -y git stow zsh fzf
git clone git@github.com:dosedaf/fedora.git ~/fedora
~/fedora/scripts/install.sh
```

Then:

1. `chsh -s /usr/bin/zsh`
2. pick packages: `scripts/pick-packages.sh dnf`, repeat for `flatpak`/`brew`/`npm`/`uv`, then `scripts/install-selected.sh`
3. non-manager installs: `packages/manual.md`
4. secrets: decrypt the backup into `$HOME` (SAFETY.md)
5. shell plugins: oh-my-zsh + `zsh-autosuggestions` + `zsh-syntax-highlighting`
6. nvim: `:Lazy sync`, then `:Mason`
7. `sudo dnf install restic` and restore data (separate backup)

## Tracked

| Path | What |
|---|---|
| `zsh/.zshrc`, `zsh/.aliases.zsh` | shell, aliases, `y()` |
| `wezterm/` | wezterm config |
| `yazi/` | minimal yazi config |
| `btop/` | btop config |
| `gnome/` | dconf dumps, monitors, mimeapps, autostart, wallpaper |
| `vscode/` | settings, keybinds, snippets, extensions |
| `fonts/` | JetBrainsMono |
| `packages/` | snapshots + picker |
| `scripts/` | install / restore / package helpers |

Not tracked: secrets, SSH/GPG keys, browser profiles, shell history, app data.
