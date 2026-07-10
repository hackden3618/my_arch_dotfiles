--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/kanagawa.lua
--
-- Purpose:
--   Plugin specification for the Kanagawa theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    kanagawa.nvim
--
-- Responsibilities:
--   • Provide Kanagawa as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-kanagawa.lua.
--
-- Notes:
--   This plugin is NOT loaded at startup — only when the user switches
--   to this theme via :ThemeSet kanagawa.
--------------------------------------------------------------------------------

return {

    "rebelot/kanagawa.nvim",

    name = "kanagawa",

    lazy = true,

    config = function()
        require("kanagawa").setup(
            require("plugins.ui.config.theme-kanagawa")
        )
    end,

}
