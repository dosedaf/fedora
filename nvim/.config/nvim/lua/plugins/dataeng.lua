return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "sql",
        "yaml",
        "json",
        "bash",
        "toml",
        "dockerfile",
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- sql
        -- "sqlfluff",

        -- shell
        "shfmt",
        "shellcheck",

        -- yaml/json
        -- "yamllint",
        "json-lsp",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- sqlls = {},
        -- dbt_ls = {},

        yamlls = {},
        jsonls = {},
      },
    },
  },

  {
    "hat0uma/csvview.nvim",
    ft = "csv",
    opts = {},
  },

  {
    "ekalinin/Dockerfile.vim",
  },

  {
    "tpope/vim-dotenv",
  },
}
