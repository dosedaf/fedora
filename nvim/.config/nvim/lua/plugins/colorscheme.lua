-- Active colorscheme. Switch by changing this one string:
--   "oxocarbon" | "carvion" | "kanagawa" | "cendre" | "flume-mira"
--   | "flume-dusk" | "flume-mesa" | "flume-opal" | "cole" | "blackout"
-- The theme plugin is lazy-loaded by lazy.nvim when LazyVim loads it.
local theme = "oxocarbon"

return {
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
