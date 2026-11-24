# waybar, technical notes

Everything the main README leaves out: exact formats, glyphs, colours,
commands, and the two traps in the workspace naming.

## Deployment

Files here are stowed from `~/fedora/sway/.config/waybar` into
`~/.config/waybar`:

| File | Role |
|---|---|
| `config` | waybar JSON, `//` comments allowed |
| `style.css` | GTK CSS, Blackout palette |
| `README.md` | what the bar is, no detail |
| `TECHNICAL.md` | this file |

## Modules and formats

| Module | Format | Detail |
|---|---|---|
| `sway/workspaces` | `●` | literal format, one dot per existing workspace; `all-outputs: false` so a bar lists only its own output's |
| `sway/mode` | `<i>{}</i>` | shows `resize` only while in that mode |
| `sway/window` | `{title}` | `max-length` 60, `JetBrainsMono Nerd Font Mono` 12px semibold (600), `#c0c0c0` |
| `pulseaudio` | `{volume}% {icon}` | icons `U+F026` to `U+F028` by level; muted `U+F6A9` plus `format_source` `U+F130`; `on-click` runs `pavucontrol` |
| `network` | see below | `interval` 1s |
| `clock` | default `{:%H:%M}` | bold white, no date, no calendar tooltip |

Network states:

| State | Renders |
|---|---|
| `format-wifi` | `U+F1EB` alone, no SSID or signal |
| `format-ethernet` | `gacorrr` |
| `format-linked` | `{ifname} (No IP) U+F796` |
| `format-disconnected` | `Disconnected U+26A0` |
| `format-alt` (on click) | `{ifname}: {ipaddr}/{cidr}` |

Not configured: battery, tray, cpu, memory, backlight, scratchpad,
idle_inhibitor. Rules for them still exist at the bottom of `style.css`, in
greyscale, so adding one later does not drag a rainbow back in.

## Workspace naming

Sway workspace names are global, so two monitors cannot both own a workspace
literally called `2`. Names therefore encode the output:

```
1:HDMI-A-1   2:HDMI-A-1   3:HDMI-A-1
1:eDP-1      2:eDP-1      3:eDP-1
```

`sway/.local/bin/sway-ws` is what the keybindings call:

```sh
sway-ws go 2      # switch to 2:<focused output>
sway-ws move 2    # move the focused container there
```

It resolves the output with `swaymsg -t get_outputs -r`, so a single monitor
needs no special case and hotplug needs no reload.

`sway/.local/bin/sway-monitor` handles the cross-screen keys. It sorts active
outputs by `rect.x`, wraps to the next one, and exits quietly when only one
output is active:

```sh
sway-monitor focus   # focus output <next>
sway-monitor move    # move container to output <next>
```

### Dots instead of numbers

The label is a single `●` per workspace, so the digit is position, not text.
Colour carries the state, through the styles waybar exposes on
`#workspaces button`: `.visible`, `.focused`, `.urgent`.

Only workspaces that exist get a dot. There is no `persistent-workspaces`
entry on purpose, so an untouched screen shows one dot, not ten. Position
still tells you which workspace you are looking at because sway keeps the
dots in numeric order: the second dot from the left is workspace 2 on that
output.

### Traps

1. Names must start with the number. `<output>:<n>` sort as `3 2 1` because
   sway orders non-numeric names by insertion; `<n>:<output>` sorts `1 2 3`
   numerically.
2. `$mod+Shift+<n>` moves within the current screen. Crossing screens is
   `$mod+Shift+m`, not a workspace number.
3. A sway restart has been seen to drop the prefixes and leave plain `1`, `2`
   workspaces behind. Their windows then sit somewhere no digit reaches, and
   two workspaces end up claiming the same dot. `sway-ws` adopts a bare numeric
   workspace on the focused output the first time you press that digit,
   renaming it to `<n>:<output>`, so the windows come back into the scheme.

## Palette

| | Hex |
|---|---|
| bar background | `#000000` |
| bottom border | `1px #282828` |
| default text | `#c0c0c0` |
| muted, idle, unfocused | `#606060` |
| clock | `#ffffff` |
| workspace dot, holds windows | `#707070` |
| workspace dot, visible on its output | `#c0c0c0` |
| workspace dot, focused | `#ffffff` |
| urgent workspace | `#000000` on `#ffffff` |

Font stack: `JetBrains Mono`, `Font Awesome 6 Free`, `sans-serif`. Glyphs need
`fontawesome-6-free-fonts`; an empty box means it is missing.

## Reload, preview, validate

```sh
kill -SIGUSR2 $(pgrep -x waybar)          # apply config and style, no restart
```

Preview on the bottom edge while the real bar stays on top:

```sh
sed 's/"position": "top"/"position": "bottom"/' \
    ~/.config/waybar/config > /tmp/wb-preview.json
waybar -c /tmp/wb-preview.json -s ~/.config/waybar/style.css &
# look, then:
kill %1
```

Check the JSON, since `jq` rejects the `//` comments waybar accepts:

```sh
grep -v '^\s*//' ~/.config/waybar/config | jq .
```

## Tunables

- Workspaces, window title, volume and network are all `font-weight: 600`,
  the clock is `bold`. Drop the weights in `style.css` if the panel reads too
  heavy at 12 to 13px.
- Workspaces sit 10px off the left edge: `.modules-left > widget:first-child >
  #workspaces` sets that margin, since the usual rule zeroes it out.
- `height` 33, `spacing` 9, `border-radius` 1px and the 3px
  `margin-top`/`margin-bottom` on modules give the floating pill look. Drop
  the margins for a flush bar.
- `layer` is `top`, `position` is `top`.
- `format-wifi` is a bare glyph. `{essid} ({signalStrength}%) ` plus `U+F1EB`
  brings information back.

Shape and module formats started as `~/nix/home/waybar/default.nix`.
