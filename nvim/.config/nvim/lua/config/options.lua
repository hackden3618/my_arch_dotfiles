--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/config/options.lua
--
-- Purpose:
--   Configure Neovim's built-in behaviour.
--
-- Responsibilities:
--   • UI settings
--   • Editing behaviour
--   • Search behaviour
--   • Indentation
--   • Splits
--   • Performance
--
-- Notes:
--   Plugin-specific options should remain inside their respective plugin
--   configurations.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Local Aliases
--------------------------------------------------------------------------------

local opt              = vim.opt
local g                = vim.g

--------------------------------------------------------------------------------
-- Disable netrw
--------------------------------------------------------------------------------
--
-- Must be set BEFORE lazy.nvim loads to prevent netrw from opening.
-- nvim-tree.lua (Explorer Engine) replaces netrw entirely.
--------------------------------------------------------------------------------

g.loaded_netrw         = 1
g.loaded_netrwPlugin   = 1

--------------------------------------------------------------------------------
-- Leader Keys
--------------------------------------------------------------------------------
--
-- Must be defined before any mappings are created.
--------------------------------------------------------------------------------

g.mapleader            = " "
g.maplocalleader       = "\\"

--------------------------------------------------------------------------------
-- User Interface
--------------------------------------------------------------------------------

opt.number             = true
opt.relativenumber     = true

opt.cursorline         = true

opt.signcolumn         = "yes"

opt.wrap               = true

opt.scrolloff          = 8
opt.sidescrolloff      = 8

opt.termguicolors      = true

opt.showmode           = false

opt.laststatus         = 3

opt.splitbelow         = true
opt.splitright         = true

--------------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------------

opt.expandtab          = true

opt.shiftwidth         = 4
opt.tabstop            = 4
opt.softtabstop        = 4

opt.smartindent        = true

opt.undofile           = true

opt.backspace          = {
    "indent",
    "eol",
    "start",
}

opt.clipboard          = "unnamedplus"

--------------------------------------------------------------------------------
-- Searching
--------------------------------------------------------------------------------

opt.ignorecase         = true
opt.smartcase          = true

opt.hlsearch           = true
opt.incsearch          = true

--------------------------------------------------------------------------------
-- Mouse
--------------------------------------------------------------------------------

opt.mouse              = "a"

--------------------------------------------------------------------------------
-- Timing
--------------------------------------------------------------------------------

opt.updatetime         = 250
opt.timeoutlen         = 300

--------------------------------------------------------------------------------
-- Completion
--------------------------------------------------------------------------------

opt.completeopt        = {
    "menu",
    "menuone",
    "noselect",
}

--------------------------------------------------------------------------------
-- Command-line completion
--------------------------------------------------------------------------------

opt.wildmode            = "longest:full,full"

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------

opt.swapfile           = true
opt.backup             = false
opt.writebackup        = false

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------
--
-- Treesitter will later replace these settings. comment all vim.opt.fold* if treesitter installed
--------------------------------------------------------------------------------
opt.foldmethod     = "expr"
opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable     = true
opt.foldlevelstart = 99 -- Open all folds on file load
-- opt.foldmethod = "manual"

vim.keymap.set("n", "<leader>ra", function()
  local f = vim.fn.expand("%")
  local out = vim.fn.expand("%:r")
  vim.cmd("w")
  vim.cmd("terminal nasm -f elf64 " .. f .. " && ld -o " .. out .. " " .. out .. ".o && ./" .. out)
end, { desc = "Assemble & Run" })   

vim.keymap.set("n", "<F6>", "<cmd>CompilerOpen<cr>", { desc = "Build & Run" })
vim.keymap.set("n", "<F7>", "<cmd>CompilerToggleResults<cr>", { desc = "Toggle Results" })
vim.keymap.set("n", "<F8>", "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", { desc = "Redo" })   
--------------------------------------------------------------------------------
-- End of File
--------------------------------------------------------------------------------
