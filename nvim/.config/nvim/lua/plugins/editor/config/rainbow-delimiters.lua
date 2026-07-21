--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/rainbow-delimiters.lua
--
-- Purpose:
--   Configuration for the Rainbow Delimiters Engine.
--
-- Responsibilities:
--   • Configure rainbow-delimiters.nvim strategy, queries, and colours.
--
-- Notes:
--   The strategy determines how matching delimiters are highlighted:
--     "global"  → highlights both delimiter and its match globally
--     "local"   → highlights only the delimiter the cursor is on
--
--   Each key in the strategy and query tables is a filetype.
--   The empty string key ('') sets the default for all filetypes.
--
--   Priority controls the highlight precedence (default 110),
--   which can be adjusted per filetype to avoid conflicts.
--------------------------------------------------------------------------------

return {
    strategy = {
        [""] = "rainbow-delimiters.strategy.global",
    },
    query = {
        [""] = "rainbow-delimiters",
        lua  = "rainbow-blocks",
    },
    priority = {
        [""] = 110,
    },
    highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
    },
}
