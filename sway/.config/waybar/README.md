# waybar

The bar for sway. Black, quiet, and it always knows which monitor you are on.

## Isolated layouting, one layout per monitor

Every output is its own island. Its own workspaces 1 to 10, its own
numbering, its own apps. Nothing bleeds between screens and no digit is
wasted on a monitor you are not even looking at.

So `$mod+2` means "the second workspace of this screen", and it means that on
either screen. The bar follows along: each one only lists the workspaces of
the output it sits on, and each one numbers them from 1. Two displays, two
independent layouts, no shared counter. It is, genuinely, the correct way to
use two monitors.

## What it looks like

Two modes, switched with one command.

`waybar-ws-mode dots` keeps a dot for every slot, so you can always see where
workspace 7 is before you use it:

![waybar, dots mode](waybar-dots.png)

`waybar-ws-mode occupied` draws a dot only where a window actually exists:

![waybar, occupied mode](waybar-occupied.png)

- Left: one dot per workspace, in numeric order, so position is the number.
  White is where you are, mid grey holds windows.
- Middle: title of the window you are looking at, in a nerd font.
- Right: volume, network, time. Volume clicks through to `pavucontrol`.

No battery, no tray, no cpu graphs. It is a bar, not a dashboard.

## Getting around

| Key | Does |
|---|---|
| `$mod+1` to `$mod+0` | workspace 1 to 10 on this screen |
| `$mod+Shift+1` to `$mod+Shift+0` | send the window to workspace 1 to 10 on this screen |
| `$mod+m` | jump to the other screen |
| `$mod+Shift+m` | send the window to the other screen |

Unplug the external monitor and none of it changes: the digits still work,
`$mod+m` just stops doing anything.

## The boring parts

Naming, glyphs, palettes, reload commands and the traps worth knowing live in
[TECHNICAL.md](TECHNICAL.md).
