-- Oxocarbon (nyoom.nvim) for Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- oxocarbon, same values Neovim's terminal colors use
local oxo = {
  bg = "#161616",
  fg = "#d0d0d0",
  black = "#262626",
  bright_black = "#525252",
  red = "#33b1ff",
  green = "#be95ff",
  yellow = "#42be65",
  blue = "#78a9ff",
  magenta = "#82cfff",
  cyan = "#3ddbd9",
  white = "#f2f2f2",
  bright_red = "#33b1ff",
  bright_green = "#be95ff",
  bright_yellow = "#42be65",
  bright_blue = "#78a9ff",
  bright_magenta = "#82cfff",
  bright_cyan = "#08bdba",
  bright_white = "#ffffff",
}

config.colors = {
  foreground = oxo.fg,
  background = oxo.bg,
  cursor_bg = oxo.fg,
  cursor_fg = oxo.bg,
  cursor_border = oxo.fg,
  selection_fg = oxo.fg,
  selection_bg = "#393939",
  scrollbar_thumb = oxo.bright_black,
  split = oxo.black,
  ansi = {
    oxo.black,
    oxo.red,
    oxo.green,
    oxo.yellow,
    oxo.blue,
    oxo.magenta,
    oxo.cyan,
    oxo.white,
  },
  brights = {
    oxo.bright_black,
    oxo.bright_red,
    oxo.bright_green,
    oxo.bright_yellow,
    oxo.bright_blue,
    oxo.bright_magenta,
    oxo.bright_cyan,
    oxo.bright_white,
  },
  tab_bar = {
    background = oxo.bg,
    active_tab = { bg_color = oxo.black, fg_color = oxo.bright_white },
    inactive_tab = { bg_color = oxo.bg, fg_color = oxo.bright_black },
    inactive_tab_hover = { bg_color = oxo.black, fg_color = oxo.fg },
    new_tab = { bg_color = oxo.bg, fg_color = oxo.bright_black },
    new_tab_hover = { bg_color = oxo.black, fg_color = oxo.fg },
  },
}

config.window_frame = {
  active_titlebar_bg = oxo.bg,
  inactive_titlebar_bg = oxo.bg,
  active_titlebar_fg = oxo.fg,
  inactive_titlebar_fg = oxo.bright_black,
  active_titlebar_border_bottom = oxo.black,
  inactive_titlebar_border_bottom = oxo.bg,
  button_fg = oxo.fg,
  button_bg = oxo.bg,
  button_hover_fg = oxo.bg,
  button_hover_bg = oxo.blue,
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
