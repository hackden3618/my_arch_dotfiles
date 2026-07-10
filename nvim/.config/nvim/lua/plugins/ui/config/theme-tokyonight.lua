--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-tokyonight.lua
--
-- Purpose:
--   Configuration for the Tokyo Night theme.
--
-- Notes:
--   Style options: "storm" (default), "moon", "night", "day"
--   The PDE uses "moon" for a muted, easy-on-the-eyes variant.
--------------------------------------------------------------------------------

return {

    style = "moon",

    transparent = true,

    terminal_colors = true,

    styles = {
        comments  = { italic = true },
        keywords  = { italic = true },
        functions = {},
        variables = {},
        strings   = {},
    },

    sidebars = { "nvterm", "NvimTree" },

    day_brightness = 0.3,

    dim_inactive = false,

    lualine_bold = false,

}
