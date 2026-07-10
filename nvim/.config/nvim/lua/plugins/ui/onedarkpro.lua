--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/onedarkpro.lua
--
-- Purpose:
--   Plugin specification for the OneDark Pro theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    onedarkpro.nvim
--
-- Responsibilities:
--   • Provide OneDark Pro as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-onedarkpro.lua.
--
-- Notes:
--   This plugin is NOT loaded at startup — only when the user switches
--   to this theme via :ThemeSet onedarkpro.
--------------------------------------------------------------------------------

return {

    "olimorris/onedarkpro.nvim",

    name = "onedarkpro",

    lazy = true,

    config = function()
        require("onedarkpro").setup(
            require("plugins.ui.config.theme-onedarkpro")
        )
    end,

}
