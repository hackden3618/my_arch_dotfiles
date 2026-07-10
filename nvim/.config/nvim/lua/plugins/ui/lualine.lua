--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/lualine.lua
--
-- Purpose:
--   Plugin specification for the Status Engine adapter.
--
-- Subsystem:  UI › Status Engine
-- Adapter:    lualine.nvim
--
-- Responsibilities:
--   • Declare lualine.nvim and nvim-web-devicons as dependencies.
--   • Load at startup (not lazy) since the statusline must be present
--     immediately upon Neovim startup.
--   • Delegate all configuration to config/lualine.lua.
--
-- Notes:
--   lualine is intentionally NOT lazy-loaded. A statusline that appears
--   late creates a jarring visual flash and degrades first-impression UX.
--------------------------------------------------------------------------------

return {

    "nvim-lualine/lualine.nvim",

    lazy = false,

    priority = 900,

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = function()
        return require("plugins.ui.config.lualine").get_config()
    end,

}
