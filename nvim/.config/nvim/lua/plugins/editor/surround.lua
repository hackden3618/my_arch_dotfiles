--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/surround.lua
--
-- Purpose:
--   Plugin specification for the Surround Engine adapter.
--
-- Subsystem:  Editor › Surround Engine
-- Adapter:    nvim-surround
--
-- Responsibilities:
--   • Declare nvim-surround as a plugin.
--   • Lazy-load on VeryLazy to avoid startup cost.
--   • Delegate configuration to config/surround.lua.
--
-- Notes:
--   nvim-surround provides motions to add, change, and delete
--   surrounding delimiters (quotes, brackets, tags, etc.).
--
--   Default keymaps:
--     ds{char}          → Delete surrounding (e.g. ds" deletes quotes)
--     cs{char}{char}    → Change surrounding
--     ys{motion}{char}  → Add surrounding
--     S{char}           → Surround in Visual mode
--------------------------------------------------------------------------------

return {

    "kylechui/nvim-surround",

    version = "*",

    event = "VeryLazy",

    opts = function()
        return require("plugins.editor.config.surround")
    end,

}
