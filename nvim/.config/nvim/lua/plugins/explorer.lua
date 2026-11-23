-- Sidebar file tree (neo-tree), styled like the fern panel in the nyoom shot.
return {
  -- snacks explorer stays off
  {
    "folke/snacks.nvim",

    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },

    opts = {
      explorer = {
        enabled = false,
      },
    },
  },

  -- oil is kept installed but off; flip `enabled` back to true to return to it
  {
    "stevearc/oil.nvim",
    enabled = false,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",

    cmd = "Neotree",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },

    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer (root dir)",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer (cwd)",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer explorer",
      },
    },

    -- open the sidebar automatically when nvim starts on a project
    init = function()
      local group = vim.api.nvim_create_augroup("nyoom_auto_tree", { clear = true })

      -- let neo-tree hijack netrw early when nvim is started on a directory
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        once = true,
        callback = function()
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
          -- no file/dir argument: dashboard, leave it alone
          if vim.fn.argc(-1) == 0 then
            return
          end

          local skip = {
            gitcommit = true,
            gitrebase = true,
            dashboard = true,
            alpha = true,
            snacks_dashboard = true,
            lazy = true,
            mason = true,
          }
          if skip[vim.bo.filetype] then
            return
          end

          local name = vim.api.nvim_buf_get_name(0)
          if name == "" then
            return
          end

          -- too narrow for a sidebar
          if vim.o.columns < 100 then
            return
          end

          -- already visible (session restore / netrw hijack)
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
              return
            end
          end

          local root = LazyVim.root()
          if root == vim.env.HOME then
            return
          end

          local is_dir = vim.fn.isdirectory(name) == 1

          vim.defer_fn(function()
            local ok, command = pcall(require, "neo-tree.command")
            if not ok then
              return
            end
            command.execute({
              action = is_dir and "focus" or "show",
              source = "filesystem",
              position = "left",
              dir = root,
              reveal = true,
            })
          end, 100)
        end,
      })
    end,

    opts = {
      close_if_last_window = true,      popup_border_style = "rounded",
      hide_root_node = true,
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },

      window = {
        position = "left",
        width = 25,
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
      },

      default_component_configs = {
        indent = {
          with_markers = false, -- nyoom has no indent markers
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "󰱒",
            conflict = "",
          },
        },
      },

      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true, -- show dotfiles, like the screenshot's tree
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
            ".ruff_cache",
            ".pytest_cache",
            ".mypy_cache",
            ".tox",
            ".venv",
            "venv",
            "node_modules",
            "__pycache__",
            "target",
            ".cache",
            ".DS_Store",
          },
        },
      },
    },

    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

      require("neo-tree").setup(opts)
    end,
  },
}
