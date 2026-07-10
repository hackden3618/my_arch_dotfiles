--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/git/fugitive.lua
--
-- Purpose:
--   Plugin specification for the Version Control Engine (repo adapter).
--
-- Subsystem:  Git › Version Control Engine
-- Adapter:    vim-fugitive
--
-- Responsibilities:
--   • Declare vim-fugitive as a plugin.
--   • Lazy-load on the Git commands that trigger it.
--   • Delegate all keymaps to config/keymaps.lua.
--
-- Notes:
--   vim-fugitive provides repo-level git operations:
--     • :Git status (:G) — the main fugitive interface
--     • :Git commit, push, pull, log, blame
--     • Full diff viewing and interactive staging
--
--   Complements gitsigns (hunk-level) with repo-level operations.
--------------------------------------------------------------------------------

return {

    "tpope/vim-fugitive",

    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep" },

    keys = function()
        return require("plugins.git.config.keymaps").keys
    end,

}
