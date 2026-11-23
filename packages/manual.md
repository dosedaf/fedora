# Not covered by package snapshots

Things installed outside dnf/flatpak/brew/npm/uv. Reinstall by hand.

## Toolchains

- rustup -> `~/.cargo`, `~/.rustup`
- nvm -> `~/.nvm` (node versions)
- Homebrew on Linux -> `/home/linuxbrew` (node, python@3.14, merve, repomix)
- Flutter SDK -> `~/sdk/flutter`
- Android SDK -> `~/Android/Sdk`
- Go -> `/usr/bin/go` (dnf), modules in `~/go`
- Java 21 (dnf)
- uv tools: see `packages/uv.txt` (installed with `uv tool install`)
- npm globals: see `packages/npm.txt` (`npm install -g`)

## Shell

- oh-my-zsh -> `~/.oh-my-zsh`, theme `arrow`
- plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting` in `~/.oh-my-zsh/custom/plugins`
- fzf shell integration -> `~/.fzf`, `~/.fzf.zsh` (`$(brew --prefix)/opt/fzf/install` equivalent)
- zoxide, eza, bat, yazi (dnf)

## Desktop

- GNOME extensions (dnf): appindicator, apps-menu, background-logo,
  launch-new-instance, places-menu, window-list
- NVIDIA akmods, RPM Fusion, ProtonVPN repo
- `/opt/xdman` (Xtreme Download Manager)
- VirtualBox 7.2 (dnf repo)
- Docker Desktop (rpm), Docker CE
- Google Chrome (dnf repo)
- Zen Browser (flatpak? check `packages/flatpak.txt`)

## Binaries in ~/.local/bin

- clickhouse, clickhousectl, duckdb, hex, ardia, lockin, opencode

## User services / cron

- `~/.config/systemd/user/`: hex, openclaw-gateway, pi-telegram, obs-todo
- crontab: `@reboot sudo nbfc start`

## Repos / system config

- RPM Fusion free + nonfree
- ProtonVPN repo
- Google Chrome repo
- Nix (multi-user install)
- ufw, sshd config, hostname, locale/timezone

Credentials for all of the above: see `SAFETY.md`.
