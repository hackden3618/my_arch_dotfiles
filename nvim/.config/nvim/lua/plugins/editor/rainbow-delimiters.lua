--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/rainbow-delimiters.lua
--
-- Purpose:
--   Plugin specification for the Rainbow Delimiters Engine adapter.
--
-- Subsystem:  Editor › Rainbow Delimiters Engine
-- Adapter:    rainbow-delimiters.nvim
--
-- Responsibilities:
--   • Declare rainbow-delimiters.nvim as a plugin.
--   • Delegate configuration to config/rainbow-delimiters.lua.
--
-- Notes:
--   rainbow-delimiters.nvim uses treesitter to highlight matching
--   delimiter pairs with distinct colours, making it easy to spot
--   mismatched brackets, parentheses, and braces.
--------------------------------------------------------------------------------

return {

    "HiPhish/rainbow-delimiters.nvim",

    event = { "BufReadPre", "BufNewFile" },

    config = function()
        require("rainbow-delimiters.setup").setup(
            require("plugins.editor.config.rainbow-delimiters")
        )
    end,

}
