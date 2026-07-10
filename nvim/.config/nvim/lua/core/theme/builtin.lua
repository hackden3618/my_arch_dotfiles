-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme/builtin.lua
--
-- Purpose:
--   Registry of built-in theme metadata for the Theme Engine.
--
-- Responsibilities:
--   • Declare the canonical list of built-in themes.
--   • Map each theme name to its Neovim colorscheme, lualine theme,
--     and display label.
--
-- Notes:
--   Each entry defines the theme's static properties. The actual
--   colorscheme plugins live in plugins/ui/*.lua as lazy-loaded
--   plugin specs. The "system" theme is NOT listed here — it is
--   generated dynamically by core/theme/system.lua.
--
--   Theme entries may optionally include a `highlights` table for
--   custom highlight overrides applied after the colorscheme runs.
-------------------------------------------------------------------------------

return {

    catppuccin = {
        name        = "catppuccin",
        label       = "Catppuccin Mocha",
        colorscheme = "catppuccin",
        lualine     = "catppuccin-mocha",
        plugin      = "catppuccin",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    tokyonight = {
        name        = "tokyonight",
        label       = "Tokyo Night (Moon)",
        colorscheme = "tokyonight",
        lualine     = "tokyonight",
        plugin      = "tokyonight",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    everforest = {
        name        = "everforest",
        label       = "Everforest (Soft)",
        colorscheme = "everforest",
        lualine     = "everforest",
        plugin      = "everforest",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    gruvbox = {
        name        = "gruvbox",
        label       = "Gruvbox (Material Dark)",
        colorscheme = "gruvbox",
        lualine     = "gruvbox",
        plugin      = "gruvbox",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    kanagawa = {
        name        = "kanagawa",
        label       = "Kanagawa (Wave)",
        colorscheme = "kanagawa",
        lualine     = "kanagawa",
        plugin      = "kanagawa",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    nord = {
        name        = "nord",
        label       = "Nord",
        colorscheme = "nord",
        lualine     = "nord",
        plugin      = "nord",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    onedarkpro = {
        name        = "onedarkpro",
        label       = "OneDark Pro",
        colorscheme = "onedark",
        lualine     = "onedark",
        plugin      = "onedarkpro",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

    dracula = {
        name        = "dracula",
        label       = "Dracula",
        colorscheme = "dracula",
        lualine     = "dracula",
        plugin      = "dracula",
        type        = "dark",
        highlights  = {},
        defs        = {},
    },

}
