--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/gruvbox.lua
--
-- Purpose:
--   Plugin specification for the Gruvbox theme.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    gruvbox.nvim
--
-- Responsibilities:
--   • Provide Gruvbox as an optional lazy-loaded theme.
--   • Load on demand when the theme manager switches to it.
--   • Delegate configuration to config/theme-gruvbox.lua.
--
-- Notes:
--   Uses ellisonleao/gruvbox.nvim (material-style, modern gruvbox).
--   This plugin is NOT loaded at startup.
--------------------------------------------------------------------------------

return {

    "ellisonleao/gruvbox.nvim",

    name = "gruvbox",

    lazy = true,

    config = function()
        require("gruvbox").setup(
            require("plugins.ui.config.theme-gruvbox")
        )
    end,

}
