--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/git/gitsigns.lua
--
-- Purpose:
--   Plugin specification for the Version Control Engine (hunk adapter).
--
-- Subsystem:  Git › Version Control Engine
-- Adapter:    gitsigns.nvim
--
-- Responsibilities:
--   • Declare gitsigns.nvim as a plugin.
--   • Load early (BufReadPost) so gutter signs appear immediately.
--   • Delegate options and keymaps to config/gitsigns.lua.
--
-- Notes:
--   gitsigns provides hunk-level git operations:
--     • Gutter signs for added/changed/deleted lines
--     • Hunk staging, resetting, and previewing
--     • Inline git blame
--     • Hunk navigation ([h / ]h)
--------------------------------------------------------------------------------


return {

    "lewis6991/gitsigns.nvim",

    event = { "BufReadPost", "BufNewFile" },

    config = function()

        local cfg      = require("plugins.git.config.gitsigns")
        local gitsigns = require("gitsigns")

        gitsigns.setup(vim.tbl_extend("force", cfg.opts, {

            on_attach = function(_bufnr)
                -- Pass the gitsigns module to setup_keymaps so it can
                -- bind directly to gitsigns functions (stage_hunk, etc.)
                cfg.setup_keymaps(gitsigns)
            end,

        }))

    end,

}
