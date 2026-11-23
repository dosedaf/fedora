-- nyoom-style modeline: nyoom's mode labels, filename, (λ • branch),
-- diagnostics, filetype and line:col, on a single full-width bar.
return {
  {
    "nvim-lualine/lualine.nvim",

    opts = function(_, opts)
      local satellite = {
        bg = "#030813",
        fg = "#ddddcc",
        panel = "#202030",
        dim = "#738c73",
        keyword = "#cda869",
        string = "#8f9d6a",
        number = "#a4c260",
        bool = "#aa88aa",
        white = "#f7f7f1",
        salmon = "#fa8072",
      }

      local theme = "auto"
      if vim.g.colors_name == "satellite" then
        theme = {
          normal = {
            a = { fg = satellite.bg, bg = satellite.keyword, gui = "bold" },
            b = { fg = satellite.fg, bg = satellite.panel },
            c = { fg = satellite.dim, bg = satellite.bg },
            z = { fg = satellite.fg, bg = satellite.bg },
          },
          insert = { a = { fg = satellite.bg, bg = satellite.string, gui = "bold" } },
          visual = { a = { fg = satellite.bg, bg = satellite.bool, gui = "bold" } },
          replace = { a = { fg = satellite.bg, bg = satellite.salmon, gui = "bold" } },
          command = { a = { fg = satellite.bg, bg = satellite.number, gui = "bold" } },
          terminal = { a = { fg = satellite.bg, bg = satellite.dim, gui = "bold" } },
          inactive = {
            a = { fg = satellite.dim, bg = satellite.bg },
            b = { fg = satellite.dim, bg = satellite.bg },
            c = { fg = satellite.dim, bg = satellite.bg },
            z = { fg = satellite.dim, bg = satellite.bg },
          },
        }
      end

      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = theme,
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      })

      local modes = {
        n = "RW",
        no = "RO",
        v = "**",
        V = "**",
        ["\22"] = "**", -- ctrl-v
        s = "S",
        S = "SL",
        ["\19"] = "SB", -- ctrl-s
        i = "**",
        ic = "**",
        R = "RA",
        Rv = "RV",
        c = "VIEX",
        cv = "VIEX",
        ce = "EX",
        r = "r",
        rm = "r",
        ["r?"] = "r",
        ["!"] = "!",
        t = "T",
      }

      opts.sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return modes[vim.api.nvim_get_mode().mode] or str
            end,
          },
        },
        lualine_b = {
          {
            "filename",
            path = 0,
            symbols = {
              modified = " ●",
              readonly = " RO",
              unnamed = "[No Name]",
            },
          },
        },
        lualine_c = {
          {
            "branch",
            icon = "",
            fmt = function(str)
              return "(λ • " .. str .. ")"
            end,
          },
        },
        lualine_x = { "diagnostics" },
        lualine_y = { "filetype" },
        lualine_z = { "location" },
      }

      return opts
    end,
  },
}
