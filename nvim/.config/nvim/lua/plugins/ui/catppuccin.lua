--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/catppuccin.lua
--
-- Purpose:
--   Plugin specification for the Theme Engine adapter.
--
-- Subsystem:  UI › Theme Engine
-- Adapter:    catppuccin/nvim
--
-- Responsibilities:
--   • Load catppuccin at the highest priority before all other plugins.
--   • Apply the colorscheme after setup completes.
--   • Delegate visual identity configuration to config/theme.lua.
--
-- Notes:
--   priority = 1000 ensures this loads before any UI plugin that may
--   depend on highlight groups being defined (lualine, barbar, etc.).
--
--   The config function explicitly calls vim.cmd.colorscheme() because
--   require("catppuccin").setup() configures the theme but does NOT
--   activate it — activation requires the separate colorscheme command.
--------------------------------------------------------------------------------

return {

    "catppuccin/nvim",

    name = "catppuccin",

    priority = 1000,

    lazy = false,

    config = function()

        local opts = require("plugins.ui.config.theme")

        require("catppuccin").setup(opts)

        vim.cmd.colorscheme("catppuccin")

    end,

}
