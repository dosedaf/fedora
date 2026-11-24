-- Satellite (dasch/satellite) for Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local sat = {
  bg = "#000000",
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
config.font_size = 14.0
config.line_height = 1.0

config.window_padding = { left = 16, right = 16, top = 16, bottom = 16 }
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.audible_bell = "Disabled"
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

-- ── quality of life ───────────────────────────────────────────────────────
config.window_background_opacity = 0.1
config.wayland_window_background_blur = true
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.hide_mouse_cursor_when_typing = true
config.unzoom_on_switch_pane = true
config.enable_kitty_keyboard = true
config.tab_max_width = 24

-- ── remember window size / maximized state ────────────────────────────────
-- wezterm doesn't persist geometry (upstream issue #256), so keep a tiny
-- state file. Position is not restorable on Wayland, only size.
local state_file = (wezterm.home_dir or os.getenv("HOME"))
  .. "/.local/share/wezterm/window-state.txt"

local function read_state()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local text = f:read("*a")
  f:close()

  local cols, rows, maxed, full = text:match("^(%d+) (%d+) (%d) (%d)")
  cols, rows = tonumber(cols), tonumber(rows)

  -- ignore nonsense from a stale or hand-edited file
  if not cols or not rows or cols < 20 or cols > 1000 or rows < 5 or rows > 500 then
    return nil
  end

  return { cols = cols, rows = rows, maxed = maxed == "1", full = full == "1" }
end

local saved = read_state()

if saved then
  config.initial_cols = saved.cols
  config.initial_rows = saved.rows
end

-- last size seen while not maximized/fullscreen, so un-maximizing later
-- gives back a sane window instead of the full-screen size
local last_normal = saved and { cols = saved.cols, rows = saved.rows } or nil

local function write_state(maxed, full)
  if not last_normal then
    return
  end
  local f = io.open(state_file, "w")
  if not f then
    return
  end
  f:write(string.format("%d %d %d %d\n", last_normal.cols, last_normal.rows, maxed and 1 or 0, full and 1 or 0))
  f:close()
end

-- wezterm exposes is_full_screen but not "is maximized", so a window covering
-- (nearly) the active screen is treated as maximized
local function fills_screen(dims)
  local screens = wezterm.gui.screens()
  local screen = screens and screens.active
  if not screen or not screen.width or not screen.height then
    return false
  end
  return dims.pixel_width >= screen.width * 0.9 and dims.pixel_height >= screen.height * 0.85
end

wezterm.on("window-resized", function(window, pane)
  local ok, err = pcall(function()
    local wdims = window:get_dimensions()
    local pdims = pane:get_dimensions()
    local maxed = (not wdims.is_full_screen) and fills_screen(wdims)

    if not maxed and not wdims.is_full_screen then
      last_normal = { cols = pdims.cols, rows = pdims.rows }
    end
    write_state(maxed, wdims.is_full_screen)
  end)
  if not ok then
    wezterm.log_error("wezterm window state: " .. tostring(err))
  end
end)

-- restore maximize/fullscreen once, for the first window of this process
local restored = false
wezterm.on("update-status", function(window, pane)
  if restored then
    return
  end
  restored = true

  local ok, err = pcall(function()
    if not saved then
      return
    end
    local dims = window:get_dimensions()
    if saved.full and not dims.is_full_screen then
      window:toggle_fullscreen()
    elseif saved.maxed and not fills_screen(dims) then
      window:maximize()
    end
  end)
  if not ok then
    wezterm.log_error("wezterm window restore: " .. tostring(err))
  end
end)

return config
