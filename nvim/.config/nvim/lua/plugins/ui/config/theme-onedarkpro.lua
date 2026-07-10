--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-onedarkpro.lua
--
-- Purpose:
--   Configuration for the OneDark Pro theme.
--
-- Notes:
--   Based on Atom's One Dark Pro palette.
--   filetype_hl overrides syntax highlighting for specific filetypes.
--------------------------------------------------------------------------------

return {

    -- options: "onedark", "onelight", "highcontrast", "vivid"
    colorscheme = "onedark",

    highlights = {
        -- Use deeper background for certain UI elements
        TelesocpeNormal = { bg = "#1e1e2e" },
        NvimTreeNormal  = { bg = "#1e1e2e" },
    },

    plugins = {
        treesitter    = true,
        telescope     = true,
        nvim_tree     = true,
        which_key     = true,
        barbar        = true,
        gitsigns      = true,
    },

    options = {
        cursorline     = true,
        transparency   = true,
        terminal_colors = true,
    },

}
