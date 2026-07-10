--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/surround.lua
--
-- Purpose:
--   Plugin specification for the Surround editing adapter.
--
-- Subsystem:  Editor
-- Adapter:    nvim-surround
--
-- Responsibilities:
--   • Declare nvim-surround as a plugin.
--   • Lazy-load on VeryLazy to avoid startup cost.
--
-- Notes:
--   nvim-surround provides motions to add, change, and delete
--   surrounding delimiters (quotes, brackets, tags, etc.).
--   It uses no configuration — all defaults are appropriate for the PDE.
--
--   Default keymaps (no setup required):
--     ys{motion}{char}  → Add surrounding (e.g. ysiw" → surround word with ")
--     ds{char}          → Delete surrounding
--     cs{char}{char}    → Change surrounding
--     S{char}           → Surround in Visual mode
--------------------------------------------------------------------------------

return {

    "kylechui/nvim-surround",

    version = "*",

    event = "VeryLazy",

    -- No opts needed — all defaults are correct for the PDE.

}
