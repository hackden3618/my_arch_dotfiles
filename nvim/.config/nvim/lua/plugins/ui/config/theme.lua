--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme.lua
--
-- Purpose:
--   Defines the PDE visual theme.
--
-- Notes:
--   Plugin-independent visual decisions belong here whenever possible.
--------------------------------------------------------------------------------

return {

    flavour = "mocha",

    transparent_background = true,

    term_colors = true,

    integrations = {

        cmp = true,

        treesitter = true,

        telescope = true,

        native_lsp = {

            enabled = true,

            underlines = {

                errors = { "undercurl" },

                hints = { "undercurl" },

                warnings = { "undercurl" },

                information = { "undercurl" },

            },

        },

        gitsigns = true,

        which_key = true,

        barbar = true,

    },

}
