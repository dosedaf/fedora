-- faster writes
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.list = false

-- disable backup/swap overhead
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- faster completion responsiveness
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- disable matchparen
vim.g.loaded_matchparen = 1

-- nyoom-ish ui: no line numbers, tight single statusline, rounded floats
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes:1"
-- drop snacks' 4-column statuscolumn, keep a 1-cell sign gutter like nyoom
vim.opt.statuscolumn = ""
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.fillchars:append({ eob = " ", vert = "│" })
if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.winborder = "rounded"
end

-- use the Snacks picker for vim.ui.select (LSP code actions, renames, ...)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ok, picker = pcall(require, "snacks.picker")
    if ok then
      vim.ui.select = picker.select
    end
  end,
})
