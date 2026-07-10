--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/nord.lua
--
-- Purpose:
--   Plugin specification for the Nord theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    nord.nvim
--
-- Responsibilities:
--   • Provide Nord as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-nord.lua.
--
-- Notes:
--   Uses shaunsingh/nord.nvim for the classic Nord palette.
--   This plugin is NOT loaded at startup.
--------------------------------------------------------------------------------

return {

    "shaunsingh/nord.nvim",

    name = "nord",

    lazy = true,

    config = function()
        require("nord").setup(
            require("plugins.ui.config.theme-nord")
        )
    end,

}
