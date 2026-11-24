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
| `sway/workspaces` | `●` | literal format, one dot per workspace; `all-outputs: false` so a bar lists only its own output's; `persistent-workspaces` keeps all ten slots on screen |
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
`#workspaces button`: `.empty`, `.visible`, `.focused`, `.urgent`. Ten dots
always show on each bar because `persistent-workspaces` is configured for all
ten names on both outputs.

### Traps

1. `persistent-workspaces` lists every workspace by full name with the output
   it belongs to, and there is one entry per workspace per output. Add a
   workspace beyond ten and it needs an entry there, otherwise its dot only
   appears once the workspace exists. The button label is a literal `●`, so no
   `format-icons` map is involved.
2. Names must start with the number. `<output>:<n>` sort as `3 2 1` because
   sway orders non-numeric names by insertion; `<n>:<output>` sorts `1 2 3`
   numerically.
3. `$mod+Shift+<n>` moves within the current screen. Crossing screens is
   `$mod+Shift+m`, not a workspace number.
4. A sway restart has been seen to drop the prefixes and leave plain `1`, `2`
   workspaces behind. Their windows then sit somewhere no digit reaches, and
   the bar shows the same number twice. `sway-ws` adopts a bare numeric
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
| workspace dot, empty | `#2e2e2e` |
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
- `height` 33, `spacing` 9, `border-radius` 1px and the 3px
  `margin-top`/`margin-bottom` on modules give the floating pill look. Drop
  the margins for a flush bar.
- `layer` is `top`, `position` is `top`.
- `format-wifi` is a bare glyph. `{essid} ({signalStrength}%) ` plus `U+F1EB`
  brings information back.

Shape and module formats started as `~/nix/home/waybar/default.nix`.
