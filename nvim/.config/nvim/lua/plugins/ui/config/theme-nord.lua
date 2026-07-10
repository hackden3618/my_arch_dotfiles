--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-nord.lua
--
-- Purpose:
--   Configuration for the Nord theme.
--
-- Notes:
--   Uses shaunsingh/nord.nvim for the classic Nord palette.
--   Uniform and balanced brightness — easy on the eyes for long sessions.
--------------------------------------------------------------------------------

return {

    transparent = true,

    italic = true,

    uniform_diff_background = true,

    enable_sidebar_background = false,

    bold = false,

    cursorline = true,

    integrations = {
        treesitter  = true,
        telescope   = true,
        cmp         = true,
        whichkey    = true,
        nvimtree    = true,
        lualine     = true,
        barbar      = true,
        gitsigns    = true,
        neorg       = false,
    },

}
