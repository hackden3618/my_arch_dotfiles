--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-kanagawa.lua
--
-- Purpose:
--   Configuration for the Kanagawa theme.
--
-- Notes:
--   Uses "wave" style (default) for the classic Kanagawa palette.
--   "dragon" and "lotus" are also available.
--------------------------------------------------------------------------------

return {

    compile = true,

    undercurl = true,

    commentStyle = { italic = true },
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle     = {},

    transparent = true,

    dimInactive = false,

    terminalColors = true,

    colors = {
        theme = {
            wave = {
                ui = {
                    float = {
                        bg = "none",
                    },
                },
            },
        },
    },

    overrides = function(colors)
        local theme = colors.theme
        return {
            TelescopeNormal = { bg = "none" },
            NvimTreeNormal  = { bg = "none" },
        }
    end,

    theme = "wave",

    background = {
        dark  = "wave",
        light = "lotus",
    },

}
