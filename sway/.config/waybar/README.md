# waybar

Bar for sway. Lives in `~/fedora/sway/.config/waybar`, stowed into
`~/.config/waybar`. Plain waybar JSON and CSS, nothing else.

## Isolated layouting, one layout per monitor

Every output is its own island. Its own workspaces 1 to 10, its own
numbering, its own apps. Nothing bleeds between screens and no digit is
wasted on a monitor you are not even looking at.

So `$mod+2` means "the second workspace of this screen" and it means that on
either screen. The bar follows along: each one only lists the workspaces of
the output it sits on, and each one numbers them from 1. Two displays, two
independent layouts, no shared counter. It is, genuinely, the correct way to
use two monitors.

The rest of this file is how that is wired up.

## What it shows

```
1 2 3 · resize │ window title │ 70% [spk]  [wifi]  10:28
└─ workspaces ─┘ └─ sway/window ┘ └─ pulseaudio, network, clock ─┘
```

| Module | Shows | Notes |
|---|---|---|
| `sway/workspaces` | digits only, occupied only | `all-outputs: false`: each bar lists its own output's workspaces |
| `sway/mode` | `resize` while in the resize mode | invisible otherwise |
| `sway/window` | focused window title | `JetBrainsMono Nerd Font Mono` 12px, grey, cut at 60 chars |
| `pulseaudio` | `70%` plus a speaker glyph (`U+F026` to `U+F028` by level) | muted shows `U+F6A9` plus mic `U+F130`; click opens `pavucontrol` |
| `network` | wifi glyph `U+F1EB`, `gacorrr` on ethernet | 1s poll; click switches to `ifname: ip/cidr` |
| `clock` | `10:28` | 24h, bold white |

Not in the bar: battery, tray, cpu, memory, backlight. The laptop panel
backlight is driven from sway's keys on `acpi_video1` instead.

## How the numbering is wired

Workspace names carry the output they belong to, which is what keeps the two
1 to 10 sets apart:

```
1:HDMI-A-1   2:HDMI-A-1   3:HDMI-A-1        <- external, AOC over HDMI
1:eDP-1      2:eDP-1      3:eDP-1           <- laptop panel
```

`sway-ws` (in `sway/.local/bin`) reads which output has focus from
`swaymsg -t get_outputs`, then switches or creates `<n>:<output>` there.
That is what `$mod+1..0` and `$mod+Shift+1..0` call, so a digit always means
"this screen's workspace n".

Movement between screens is separate:

| Key | Action |
|---|---|
| `$mod+m` | focus the other output, wrapping in x order |
| `$mod+Shift+m` | send the focused window to the other output |

Both come from `sway-monitor` and do nothing when only one output is active.
Unplugging the external screen needs no config change or reload: the names
stay prefixed, `sway-ws` just resolves to the remaining output, and the bar
keeps showing bare digits.

This file is the display half of that. `format-icons` maps every
`<n>:<output>` name back to its digit, which is why the bar reads `2` and not
`2:HDMI-A-1`. Two consequences:

- Workspace 11 and up needs its own `format-icons` entry, otherwise waybar
  falls back to printing the raw name.
- Ordering is numeric because names start with the number. A leading output
  name would sort the buttons as `3 2 1`.

## Palette

Black and greys only:

| | |
|---|---|
| bar background | `#000000` with a `1px #282828` bottom border |
| default text | `#c0c0c0` |
| muted, idle, unfocused | `#606060` |
| focused workspace text, clock | `#ffffff` |
| focused workspace background | `#404040` |

Glyphs come from **Font Awesome 6 Free** (`fontawesome-6-free-fonts`). An
empty box instead of an icon means that package is missing.

## Reload, preview, validate

Apply config and style without restarting the bar:

```sh
kill -SIGUSR2 $(pgrep -x waybar)
```

Preview a change on the bottom edge while the real bar stays up top:

```sh
sed 's/"position": "top"/"position": "bottom"/' \
    ~/.config/waybar/config > /tmp/wb-preview.json
waybar -c /tmp/wb-preview.json -s ~/.config/waybar/style.css &
# look, then:
kill %1
```

Check the JSON. Waybar tolerates `//` comments, `jq` does not:

```sh
grep -v '^\s*//' ~/.config/waybar/config | jq .
```

## Tunables

- `height` 33, `spacing` 9 and the 3px module insets give the floating pill
  look. `margin-top` and `margin-bottom` of 3px on modules is what keeps them
  off the bar edges; drop it for a flush bar.
- `format-wifi` is a bare wifi glyph. Swap in
  `{essid} ({signalStrength}%) ` plus the glyph if you want detail back.

Shape and module formats started as `~/nix/home/waybar/default.nix`.
