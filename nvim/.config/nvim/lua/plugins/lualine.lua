-- nyoom-style modeline: nyoom's mode labels, filename, (λ • branch),
-- diagnostics, filetype and line:col, on a single full-width bar.
return {
  {
    "nvim-lualine/lualine.nvim",

    opts = function(_, opts)
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

      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        -- follows the active colorscheme (oxocarbon ships a lualine theme)
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      })

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
