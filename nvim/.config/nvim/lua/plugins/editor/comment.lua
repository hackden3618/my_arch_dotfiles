--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/comment.lua
--
-- Purpose:
--   Plugin specification for the Comment Engine adapter.
--
-- Subsystem:  Editor › Comment Engine
-- Adapter:    Comment.nvim
--
-- Responsibilities:
--   • Declare Comment.nvim as a plugin.
--   • Lazy-load on BufReadPost to avoid startup overhead.
--   • Delegate configuration to config/comment.lua.
--
-- Notes:
--   Comment.nvim provides treesitter-aware commenting via the standard
--   gc / gcc / gb / gbc keymap convention.
--   ts-context-commentstring is included to handle embedded language
--   commenting correctly (e.g. <script> inside HTML files).
--------------------------------------------------------------------------------

return {

    "numToStr/Comment.nvim",

    event = { "BufReadPost", "BufNewFile" },

    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
    },

    opts = function()
        return require("plugins.editor.config.comment")
    end,

}
