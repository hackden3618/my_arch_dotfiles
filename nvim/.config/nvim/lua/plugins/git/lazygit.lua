--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/git/lazygit.lua
--
-- Purpose:
--   Plugin specification for the Git TUI adapter.
--
-- Subsystem:  Git › TUI Engine
-- Adapter:    lazygit.nvim
--
-- Responsibilities:
--   • Declare lazygit.nvim as a plugin.
--   • Lazy-load on <leader>gL keymap.
--
-- Notes:
--   lazygit.nvim opens the lazygit TUI inside a Neovim floating terminal.
--   It complements vim-fugitive (atomic git commands) with a visual interface
--   for complex operations: rebasing, cherry-picking, conflict resolution,
--   and branch management.
--
--   PREREQUISITE: lazygit must be installed on the system.
--     Arch:   sudo pacman -S lazygit
--     Ubuntu: brew install lazygit  (or use go install)
--     macOS:  brew install lazygit
--------------------------------------------------------------------------------

return {

    "kdheepak/lazygit.nvim",

    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    keys = {
        { "<leader>gL", "<Cmd>LazyGit<CR>",            desc = "Git: LazyGit TUI" },
        { "<leader>gF", "<Cmd>LazyGitCurrentFile<CR>", desc = "Git: LazyGit (Current File)" },
    },

}
