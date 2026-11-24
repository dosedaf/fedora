# waybar

Blackout-flavoured bar for sway, ported from the nix/hyprland config in
`~/nix/home/waybar/default.nix`. Stowed from `~/fedora/sway/.config/waybar`
into `~/.config/waybar`.

Everything here is plain waybar JSON + CSS — no nix, no home-manager.

## Layout

```
1 2 3 · resize │ window title │ 70% [spk]  [wifi]  10:28
└─ workspaces ─┘ └─ sway/window ┘ └─ pulseaudio, network, clock ─┘
```

| Module | Shows | Notes |
|---|---|---|
| `sway/workspaces` | digits only, occupied only | `all-outputs: false`, so each bar lists that output's workspaces |
| `sway/mode` | `resize` while in the resize mode | invisible otherwise |
| `sway/window` | focused window title | `JetBrainsMono Nerd Font Mono` 12px, grey, cut at 60 chars |
| `pulseaudio` | `70%` + speaker glyph `U+F026-F028` by level | muted → `U+F6A9` + mic `U+F130`; click → `pavucontrol` |
| `network` | wifi glyph `U+F1EB`, `gacorrr` on ethernet | 1s poll; click → `ifname: ip/cidr` |
| `clock` | `10:28` | 24h, bold white |

Deliberately **not** in the bar: battery, tray, cpu, memory, backlight. The
nix config had none of them either, and the laptop's backlight device
(`acpi_video1`) is handled by sway's keys instead.

## Palette

Pure black, greys only — the nix theme's Everforest colours were flattened:

| | |
|---|---|
| bar background | `#000000` + `1px #282828` bottom border |
| default text | `#c0c0c0` |
| muted / idle | `#606060` |
| focused workspace text, clock | `#ffffff` |
| focused workspace background | `#404040` |

Icons come from **Font Awesome 6 Free** (`fontawesome-6-free-fonts`). If a
glyph ever renders as an empty box, that package is missing.

## Workspaces depend on sway-ws

Names are `<n>:<output>`, e.g. `2:HDMI-A-1`, so both monitors can have their
own `2`. `format-icons` maps each name back to its bare digit — that mapping is
why the bar shows `2` and not `2:HDMI-A-1`.

That naming is created by `sway/.local/bin/sway-ws`, which `$mod+1..0` call.
**Adding workspace 11+ needs a matching `format-icons` entry**, otherwise the
raw name is shown (waybar falls back to the name for unknown keys).

## Reload / preview

Apply the live config and style without restarting the bar:

```sh
kill -SIGUSR2 $(pgrep -x waybar)
```

Preview a change on the bottom edge while the real bar keeps running on top:

```sh
sed 's/"position": "top"/"position": "bottom"/' \
    ~/.config/waybar/config > /tmp/wb-preview.json
waybar -c /tmp/wb-preview.json -s ~/.config/waybar/style.css &
# look, then:
kill %1
```

Validate the JSON (waybar tolerates `//` comments, `jq` does not):

```sh
grep -v '^\s*//' ~/.config/waybar/config | jq .
```

## Tunables

- `height` (33), `spacing` (9) and the `3px` module insets in `style.css` come
  from the nix config; they give the floating-pill look.
- `margin-top/bottom: 3px` on modules is what separates them from the bar
  edges — drop it for a flush bar.
- `format-wifi` is a bare wifi glyph. The commented alternative in the nix
  file was `{essid} ({signalStrength}%) ` + glyph if you want info back.
