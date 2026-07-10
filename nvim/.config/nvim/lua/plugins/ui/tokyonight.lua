--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/tokyonight.lua
--
-- Purpose:
--   Plugin specification for the Tokyo Night theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    tokyonight.nvim
--
-- Responsibilities:
--   • Provide Tokyo Night as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-tokyonight.lua.
--
-- Notes:
--   This plugin is NOT loaded at startup — only when the user switches
--   to this theme via :ThemeSet tokyonight.
--------------------------------------------------------------------------------

return {

    "folke/tokyonight.nvim",

    name = "tokyonight",

    lazy = true,

    config = function()
        require("tokyonight").setup(
            require("plugins.ui.config.theme-tokyonight")
        )
    end,

}
