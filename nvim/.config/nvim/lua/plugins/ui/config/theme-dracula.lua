--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-dracula.lua
--
-- Purpose:
--   Configuration for the Dracula theme.
--
-- Notes:
--   Classic Dracula palette — dark purple background, vibrant highlights.
--   All integrations enabled for full PDE compatibility.
--------------------------------------------------------------------------------

return {

    transparent = true,

    italic_comment = true,

    overrides = {},

    colors = {
        bg = "#1e1e2e",
    },

    plugins = {
        treesitter    = true,
        telescope     = true,
        nvimtree      = true,
        lualine       = true,
        whichkey      = true,
        barbar        = true,
        gitsigns      = true,
    },

}
