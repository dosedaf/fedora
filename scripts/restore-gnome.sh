#!/usr/bin/env bash
# Restore GNOME / GTK settings captured in gnome/*.ini
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/gnome"

# repoint hardcoded home paths (wallpaper etc.)
sanitize() { sed "s#/home/yoda#${HOME}#g"; }

load() {
    local file="$repo/$1" path="$2"
    [ -s "$file" ] || return 0
    sanitize <"$file" | dconf load "$path"
    echo "loaded $1 -> $path"
}

load desktop.ini       /org/gnome/desktop/
load shell.ini         /org/gnome/shell/
load settings-daemon.ini /org/gnome/settings-daemon/
load mutter.ini        /org/gnome/mutter/
load nautilus.ini      /org/gnome/nautilus/
load ptyxis.ini        /org/gnome/Ptyxis/
load gtk.ini           /org/gtk/
load login-screen.ini  /org/gnome/login-screen/

mkdir -p "$HOME/.config/autostart" "$HOME/.config/gtk-3.0"
cp -a "$repo/autostart/." "$HOME/.config/autostart/"
cp "$repo/background" "$HOME/.config/background"
cp "$repo/mimeapps.list" "$HOME/.config/mimeapps.list"
cp "$repo/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
cp "$repo/gtk-bookmarks" "$HOME/.config/gtk-3.0/bookmarks"
cp "$repo/monitors.xml" "$HOME/.config/monitors.xml"

echo "gnome settings restored"
