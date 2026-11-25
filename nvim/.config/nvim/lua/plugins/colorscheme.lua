-- Active colorscheme. Switch by changing this one string:
--   "satellite" | "oxocarbon" | "carvion" | "kanagawa" | "cendre"
--   | "flume-mira" | "flume-dusk" | "flume-mesa" | "flume-opal" | "cole" | "blackout"
-- The theme plugin is lazy-loaded by lazy.nvim when LazyVim loads it.
local theme = "satellite"

return {
  -- Satellite (Vim color scheme by dasch)
  {
    "dasch/satellite",
    lazy = true,

    -- satellite is a legacy Vim theme; fill in the Neovim-only groups
    init = function()
      local group = vim.api.nvim_create_augroup("satellite_ui", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          if vim.g.colors_name ~= "satellite" then
            return
          end

          local function hl(name, opts)
            vim.api.nvim_set_hl(0, name, opts)
          end

          hl("NormalFloat", { fg = "#ddddcc", bg = "#131823" })
          hl("FloatBorder", { fg = "#625224", bg = "#131823" })
          hl("FloatTitle", { fg = "#cda869", bg = "#131823", bold = true })
          hl("WinSeparator", { fg = "#202030", bg = "none" })
          hl("LineNr", { fg = "#303040", bg = "none" })
          hl("CursorLineNr", { fg = "#cda869", bg = "#131823" })
          hl("CursorLine", { bg = "#131823" })
          hl("Visual", { bg = "#4a708b", fg = "#f7f7f1" })

          -- let wezterm's opacity / blur show through
          hl("Normal", { fg = "#ddddcc", bg = "none" })
          hl("NormalNC", { fg = "#ddddcc", bg = "none" })
          hl("SignColumn", { fg = "#738c73", bg = "none" })
          hl("EndOfBuffer", { fg = "#131823", bg = "none" })
          hl("NeoTreeNormal", { fg = "#ddddcc", bg = "none" })
          hl("NeoTreeNormalNC", { fg = "#ddddcc", bg = "none" })
          hl("NeoTreeSignColumn", { bg = "none" })
          hl("SnacksDashboardNormal", { fg = "#ddddcc", bg = "none" })

          hl("DiagnosticError", { fg = "#fa8072" })
          hl("DiagnosticWarn", { fg = "#cda869" })
          hl("DiagnosticInfo", { fg = "#8f9d6a" })
          hl("DiagnosticHint", { fg = "#738c73" })
          hl("LspInlayHint", { fg = "#5f677a", bg = "#131823" })
          hl("SnacksDashboardHeader", { fg = "#738c73" })
          hl("SnacksDashboardKey", { fg = "#cda869" })
          hl("SnacksDashboardDesc", { fg = "#ddddcc" })
          hl("SnacksDashboardFooter", { fg = "#738c73" })
          hl("SnacksDashboardTitle", { fg = "#cda869", bold = true })
        end,
      })
    end,
  },

  -- oxocarbon, the theme nyoom.nvim is built around
  -- build = false: the repo has a rockspec, but it ships compiled lua
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = true,
    build = false,
  },

  -- Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = true,

    opts = {
      theme = "dragon",

      background = {
        dark = "dragon",
      },
    },
  },

  -- Cendre
  {
    "Aejkatappaja/cendre",
    lazy = true,
  },

  -- Flume
  {
    "mitander/flume.nvim",
    lazy = true,

    opts = {
      style = "mira",
    },
  },

  -- Cole
  {
    "thekylehuang/cole.nvim",
    lazy = true,
  },

  -- Carvion
  {
    "zitrocode/carvion.nvim",
    lazy = true,
  },

  -- Omni (colorschemes include "blackout")
  {
    "harshrajsachan/omni.nvim",
    lazy = true,
  },

  -- Load the active theme through LazyVim's colorscheme handler
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme,
    },
  },
}
