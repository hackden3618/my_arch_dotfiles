--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/git/config/keymaps.lua
--
-- Purpose:
--   Fugitive keymaps for the Version Control Engine.
--
-- Responsibilities:
--   • Git workflow keymaps using vim-fugitive commands.
--   • Staging, committing, pushing via <leader>g namespace.
--
-- Notes:
--   These keymaps complement gitsigns keymaps:
--     gitsigns → hunk-level operations (stage, reset, preview hunks)
--     fugitive → repo-level operations (status, commit, push, blame)
--
--   All commands use : prefix (cmdline mode) so the user can see
--   and optionally edit the command before execution.
--------------------------------------------------------------------------------

local M = {}

M.keys = {
    { "<leader>gg", "<Cmd>Git<CR>",           desc = "Git: Status (Fugitive)" },
    { "<leader>gA", "<Cmd>Git add .<CR>",     desc = "Git: Add All" },
    { "<leader>ga", "<Cmd>Git add %<CR>",     desc = "Git: Add Current File" },
    { "<leader>gc", ':Git commit -m ""<Left>',desc = "Git: Commit (prompt)" },
    { "<leader>gp", "<Cmd>Git push<CR>",      desc = "Git: Push" },
    { "<leader>gP", "<Cmd>Git pull<CR>",      desc = "Git: Pull" },
    { "<leader>gl", "<Cmd>Git log --oneline<CR>", desc = "Git: Log" },
}

return M
