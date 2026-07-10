--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/treesitter.lua
--
-- Purpose:
--   Plugin specification for the Syntax Engine adapter.
--
-- Subsystem:  Editor › Syntax Engine
-- Adapter:    nvim-treesitter
--
-- Responsibilities:
--   • Declare nvim-treesitter and its build step.
--   • Load before a file is read so highlighting is ready for the first buffer.
--   • Trigger `:TSUpdate` on build to keep parsers current.
--   • Delegate parser list and options to config/treesitter.lua.
--
-- Notes:
--   Treesitter powers syntax highlighting, indentation, folding,
--   and text objects across all supported languages.
--
--   The `main` field tells lazy.nvim which module to call `.setup()`
--   on, since the treesitter module name differs from the plugin name.
--------------------------------------------------------------------------------

return {

    "nvim-treesitter/nvim-treesitter",

    build = ":TSUpdate",

    event = { "BufReadPre", "BufNewFile" },

    main = "nvim-treesitter.config",

    opts = function()
        return require("plugins.editor.config.treesitter")
    end,

}
