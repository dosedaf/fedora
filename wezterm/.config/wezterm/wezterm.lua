-- Satellite (dasch/satellite) for Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local sat = {
  bg = "#030813",
  fg = "#ddddcc",
  panel = "#202030",
  cursorline = "#131823",
  dim = "#738c73",
  keyword = "#cda869",
  string = "#8f9d6a",
  number = "#a4c260",
  boolean = "#aa88aa",
  comment = "#738c73",
  white = "#f7f7f1",
}

config.colors = {
  foreground = sat.fg,
  background = sat.bg,
  cursor_bg = sat.fg,
  cursor_fg = sat.bg,
  cursor_border = sat.fg,
  selection_fg = sat.fg,
  selection_bg = sat.cursorline,
  scrollbar_thumb = sat.panel,
  split = sat.panel,
  ansi = {
    "#131823",
    "#fa8072",
    sat.string,
    sat.keyword,
    "#4a708b",
    sat.boolean,
    "#7fb8b8",
    sat.fg,
  },
  brights = {
    "#5f677a",
    "#ff9d90",
    "#a8b982",
    "#e0c084",
    "#6f95b0",
    "#c4a6c4",
    "#9fd4d4",
    sat.white,
  },
  tab_bar = {
    background = sat.bg,
    active_tab = { bg_color = sat.panel, fg_color = sat.white },
    inactive_tab = { bg_color = sat.bg, fg_color = sat.comment },
    inactive_tab_hover = { bg_color = sat.panel, fg_color = sat.fg },
    new_tab = { bg_color = sat.bg, fg_color = sat.comment },
    new_tab_hover = { bg_color = sat.panel, fg_color = sat.fg },
  },
}

config.window_frame = {
  active_titlebar_bg = sat.bg,
  inactive_titlebar_bg = sat.bg,
  active_titlebar_fg = sat.fg,
  inactive_titlebar_fg = sat.comment,
  active_titlebar_border_bottom = sat.panel,
  inactive_titlebar_border_bottom = sat.bg,
  button_fg = sat.fg,
  button_bg = sat.bg,
  button_hover_fg = sat.bg,
  button_hover_bg = sat.keyword,
}

config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
  "Noto Color Emoji",
})
config.font_size = 11.0
config.line_height = 1.0

config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.audible_bell = "Disabled"
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

return config
