#!/usr/bin/env bash
# Link configs, restore desktop state. Safe to re-run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v stow >/dev/null || { echo "install stow first: sudo dnf install stow" >&2; exit 1; }

echo "== stow"
for pkg in zsh wezterm yazi btop nvim sway; do
    [ -d "$pkg" ] && stow --no-folding -t "$HOME" "$pkg"
done

echo "== fonts"
mkdir -p "$HOME/.local/share/fonts"
cp -a fonts/*.ttf "$HOME/.local/share/fonts/"
command -v fc-cache >/dev/null && fc-cache -f >/dev/null

echo "== gnome"
read -r -p "restore GNOME settings now? [y/N] " ans
[[ "${ans:-n}" == "y" ]] && scripts/restore-gnome.sh

cat <<'EOF'

Manual steps left:
  sway     : sudo install -Dm644 ~/fedora/sway/.local/share/wayland-sessions/sway-hybrid.desktop \\
             /usr/local/share/wayland-sessions/sway-hybrid.desktop
  packages : scripts/pick-packages.sh dnf   (then flatpak/brew/npm/uv)
             scripts/install-selected.sh
  packages : packages/manual.md for non-manager installs
  shell    : oh-my-zsh + zsh-autosuggestions + zsh-syntax-highlighting
  secrets  : decrypt backup into $HOME (see SAFETY.md)
  nvim     : :Lazy sync, then :Mason
  shell    : chsh -s /usr/bin/zsh
EOF
