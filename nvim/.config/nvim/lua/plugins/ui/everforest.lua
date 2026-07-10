--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/everforest.lua
--
-- Purpose:
--   Plugin specification for the Everforest theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    everforest.nvim
--
-- Responsibilities:
--   • Provide Everforest as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-everforest.lua.
--
-- Notes:
--   This plugin is NOT loaded at startup — only when the user switches
--   to this theme via :ThemeSet everforest.
--------------------------------------------------------------------------------

return {

    "sainnhe/everforest",

    name = "everforest",

    lazy = true,

    config = function()
        require("everforest").setup(
            require("plugins.ui.config.theme-everforest")
        )
    end,

}
