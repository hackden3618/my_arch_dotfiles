--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/config/remap.lua
--
-- Purpose:
--   Registers editor-wide keymaps that belong to no specific plugin.
--
-- Responsibilities:
--   • File explorer shortcut
--   • Escape shortcuts for Insert and Visual mode
--   • Search highlight clearing
--   • Window management (split, close, navigate)
--   • Terminal opening
--   • Better movement primitives (join, half-page, search centering)
--
-- Notes:
--   Plugin-specific keymaps belong inside the corresponding plugin
--   module (e.g. telescope keymaps live in plugins/editor/config/telescope.lua).
--   This file is loaded before any plugin, so it must NOT depend on any
--   plugin being available.
--
--   All keymaps use core.keymaps to ensure consistent defaults
--   (noremap = true, silent = true) and future replaceability.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local km = require("core.keymaps")

--------------------------------------------------------------------------------
-- File Explorer
--------------------------------------------------------------------------------

km.n(
    "<leader>pv",
    vim.cmd.Ex,
    "Open netrw Explorer"
)

--------------------------------------------------------------------------------
-- Escape Shortcuts
--------------------------------------------------------------------------------

km.i("jj", "<Esc>", "Exit Insert Mode")
km.v("jk", "<Esc>", "Exit Visual Mode")

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------

km.n("<Esc>", "<cmd>nohlsearch<CR>", "Clear Search Highlight")

--------------------------------------------------------------------------------
-- Window Management
--------------------------------------------------------------------------------

km.n("<leader>wv", "<cmd>vsplit<CR>", "Vertical Split")
km.n("<leader>wb", "<cmd>split<CR>",  "Horizontal Split")
km.n("<leader>wc", "<cmd>close<CR>",  "Close Window")

--------------------------------------------------------------------------------
-- Window Navigation
--------------------------------------------------------------------------------

km.n("<leader>wh", "<C-w>h", "Focus Left Window")
km.n("<leader>wj", "<C-w>j", "Focus Lower Window")
km.n("<leader>wk", "<C-w>k", "Focus Upper Window")
km.n("<leader>wl", "<C-w>l", "Focus Right Window")

--------------------------------------------------------------------------------
-- Terminal
--------------------------------------------------------------------------------

km.n("<leader>tO", "<cmd>terminal<CR>", "Open Terminal (Built-in)")

--------------------------------------------------------------------------------
-- Better Line Movement
--------------------------------------------------------------------------------
--
-- J:    Join lines while keeping cursor position stable.
-- C-d:  Half-page down, cursor stays vertically centered.
-- C-u:  Half-page up, cursor stays vertically centered.
-- n/N:  Next/previous search result, cursor stays centered.
--------------------------------------------------------------------------------

km.n("J",     "mzJ`z",   "Join Lines (cursor stable)")
km.n("<C-d>", "<C-d>zz", "Half Page Down (centered)")
km.n("<C-u>", "<C-u>zz", "Half Page Up (centered)")
km.n("n",     "nzzzv",   "Next Search Result (centered)")
km.n("N",     "Nzzzv",   "Previous Search Result (centered)")

--------------------------------------------------------------------------------
-- Register which-key Groups
--------------------------------------------------------------------------------
--
-- These labels make which-key display readable group names when
-- the user pauses after pressing <leader>.
--
-- Plugin-specific groups are registered inside their own modules.
--------------------------------------------------------------------------------

km.group("<leader>p", "Project")
km.group("<leader>w", "Windows")
km.group("<leader>t", "Terminal")
km.group("<leader>u", "UI")

--------------------------------------------------------------------------------
-- Theme Cycling
--------------------------------------------------------------------------------

km.n("<leader>uT", "<Cmd>ThemeNext<CR>", "Theme: Cycle to Next")
km.n("<leader>ut", "<Cmd>ThemeSet<CR>",  "Theme: Set (Tab-completes)")
