-- Nyoom-flavoured bufferline: thin separators, no numbers, close icons.
return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = "none",
        indicator = {
          style = "icon",
          icon = "│",
        },
        separator_style = { "", "│" },
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = false,
      },
    },
  },
}
