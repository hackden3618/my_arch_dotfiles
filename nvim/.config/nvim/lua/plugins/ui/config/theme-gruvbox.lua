--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-gruvbox.lua
--
-- Purpose:
--   Configuration for the Gruvbox theme.
--
-- Notes:
--   Uses "material" style for a modern, desaturated gruvbox palette.
--------------------------------------------------------------------------------

return {

    italic = {
        comments = true,
        strings  = false,
        keywords = true,
        emphasis = true,
    },

    transparent_mode = true,

    terminal_colors = true,

    overrides = {},

    plugins = {
        treesitter   = true,
        telescope    = true,
        cmp          = true,
        whichkey     = true,
        nvimtree     = true,
        lualine      = true,
        barbar       = true,
        gitsigns     = true,
        indent_blankline = true,
    },

}
