--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/barbar.lua
--
-- Purpose:
--   Plugin specification for the Buffer Engine adapter.
--
-- Subsystem:  UI › Buffer Engine
-- Adapter:    barbar.nvim
--
-- Responsibilities:
--   • Declare barbar.nvim and its dependencies.
--   • Load at startup since the buffer line must be visible immediately.
--   • Delegate all visual configuration and keymaps to config/bufferline.lua.
--
-- Notes:
--   barbar.nvim shows all open buffers as tabs in the tabline with
--   git status indicators and LSP diagnostic badges per buffer.
--
--   config = function() is used here (rather than opts = ...) because
--   barbar requires both setup() AND keymap registration at load time.
--   Separating them into two lazy fields would couple spec to impl.
--------------------------------------------------------------------------------

return {

    "romgrk/barbar.nvim",

    lazy = false,

    priority = 900,

    dependencies = {
        "lewis6991/gitsigns.nvim",
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        require("plugins.ui.config.bufferline").setup()
    end,

}
