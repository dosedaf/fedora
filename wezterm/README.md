# wezterm

Single-file WezTerm setup: [Satellite](https://github.com/dasch/satellite) palette on a
pure-black background, JetBrainsMono Nerd Font at 14pt, and a small block of Lua that
remembers your window size between launches.

```
~/.config/wezterm/wezterm.lua  ->  ~/fedora/wezterm/.config/wezterm/wezterm.lua
```

## Colors

| | Hex | Where |
|---|---|---|
| background | `#000000` | everywhere |
| foreground | `#ddddcc` | text, cursor |
| panel | `#202030` | active tab, split borders |
| selection | `#131823` | highlighted text |
| yellow | `#cda869` | buttons on hover |
| green | `#8f9d6a` | |
| magenta | `#aa88aa` | |
| comment | `#738c73` | inactive tabs |
| white | `#f7f7f1` | bright white |

## Font

JetBrainsMono Nerd Font Mono, 14pt, with Noto Color Emoji as fallback.

## Nice things

- Closing a tab never asks twice.
- Zooming with `Ctrl+=` changes the text, not the window.
- The mouse cursor gets out of the way while you type.
- Switching panes un-zooms instead of leaving you stuck.
- `Ctrl+Enter` and friends reach nvim and other full-screen apps correctly.
- Long directory names get truncated instead of squashing the tab bar.
- The tab bar only shows up once there's a second tab.
- No scrollbar, no bell.

## Window size

Remembers the size you last used, plus whether it was maximized. Leave it
maximized, it comes back maximized; leave it normal, it comes back normal.

## Keys

| Key | What |
|---|---|
| `Ctrl+Shift+R` | reload this config |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | zoom in / out / reset |
| `Ctrl+Shift+F` | search the scrollback |
| `Ctrl+Shift+X` | copy mode (vim keys) |
| `Ctrl+Shift+Space` | jump to a URL or path |
| `Ctrl+Shift+T` / `Ctrl+Shift+W` | new tab / close tab |
| `Ctrl+Shift+Arrows` | move between panes |
| `Ctrl+Shift+P` | command palette |
