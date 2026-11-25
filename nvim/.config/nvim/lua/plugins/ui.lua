-- Bufferline styling; satellite gets its own palette because it is a legacy
-- Vim theme without BufferLine highlight groups.
return {
  {
    "akinsho/bufferline.nvim",

    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        numbers = "none",
        indicator = {
          style = "icon",
          icon = "│",
        },
        separator_style = { "", "│" },
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = false,
      })

      if vim.g.colors_name == "satellite" then
        opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, {
          fill = { bg = "none" },
          background = { fg = "#738c73", bg = "none" },
          buffer_selected = { fg = "#f7f7f1", bg = "#202030", bold = true, italic = true },
          buffer_visible = { fg = "#ddddcc", bg = "none" },
          separator = { fg = "#131823", bg = "none" },
          separator_selected = { fg = "#202030", bg = "#202030" },
          separator_visible = { fg = "#131823", bg = "none" },
          indicator_selected = { fg = "#cda869", bg = "#202030" },
          modified = { fg = "#cda869", bg = "none" },
          modified_selected = { fg = "#cda869", bg = "#202030" },
          close_button = { fg = "#738c73", bg = "none" },
          close_button_selected = { fg = "#fa8072", bg = "#202030" },
          duplicate = { fg = "#738c73", bg = "none" },
          duplicate_selected = { fg = "#738c73", bg = "#202030" },
        })
      end

      return opts
    end,
  },
}
