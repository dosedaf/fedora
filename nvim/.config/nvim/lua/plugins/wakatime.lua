return {
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",

    -- keep time tracking, but don't inject "N hrs N mins" into lualine
    opts = {
      status_bar_enabled = false,
    },
  },
}
