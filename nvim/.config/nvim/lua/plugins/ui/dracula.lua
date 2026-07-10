--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/dracula.lua
--
-- Purpose:
--   Plugin specification for the Dracula theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    dracula.nvim
--
-- Responsibilities:
--   • Provide Dracula as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-dracula.lua.
--
-- Notes:
--   This plugin is NOT loaded at startup — only when the user switches
--   to this theme via :ThemeSet dracula.
--------------------------------------------------------------------------------

return {

    "Mofiqul/dracula.nvim",

    name = "dracula",

    lazy = true,

    config = function()
        require("dracula").setup(
            require("plugins.ui.config.theme-dracula")
        )
    end,

}
