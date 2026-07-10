--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/trouble.lua
--
-- Purpose:
--   Plugin specification for the Diagnostics Panel adapter.
--
-- Subsystem:  UI › Diagnostics Panel
-- Adapter:    trouble.nvim
--
-- Responsibilities:
--   • Declare trouble.nvim as a plugin.
--   • Lazy-load on command invocation and keymaps.
--   • Delegate all configuration to config/trouble.lua.
--
-- Notes:
--   trouble.nvim provides a persistent, filterable panel showing all
--   workspace diagnostics, LSP references, quickfix, and location list
--   entries. It complements the inline LSP diagnostics configured in
--   plugins/lsp/config/diagnostics.lua.
--------------------------------------------------------------------------------

return {

    "folke/trouble.nvim",

    cmd = "Trouble",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    keys = function()
        return require("plugins.ui.config.trouble").keys
    end,

    opts = function()
        return require("plugins.ui.config.trouble").opts
    end,

}
