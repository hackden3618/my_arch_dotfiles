--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/telescope.lua
--
-- Purpose:
--   Plugin specification for the Search Engine adapter.
--
-- Subsystem:  Editor › Search Engine
-- Adapter:    telescope.nvim
--
-- Responsibilities:
--   • Declare telescope.nvim and all required extensions.
--   • Lazy-load on the keymaps that trigger telescope pickers.
--   • Delegate all configuration to config/telescope.lua.
--
-- Notes:
--   Extensions included:
--     telescope-fzf-native   — native C fuzzy sorter (requires `make`)
--     telescope-ui-select    — routes vim.ui.select() through telescope
--                              (used by LSP code actions, rename UI, etc.)
--
--   The ui-select extension integration is intentionally correct here:
--   load_extension() is called inside the config function AFTER setup(),
--   NOT nested inside a setup() call (which was the bug in the backup).
--------------------------------------------------------------------------------

return {

    "nvim-telescope/telescope.nvim",

    version = "*",

    cmd = "Telescope",
    event = "VeryLazy",

    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-telescope/telescope-ui-select.nvim",
    },

    keys = function()
        return require("plugins.editor.config.telescope").keys
    end,

    config = function()
        require("plugins.editor.config.telescope").setup()
    end,

}
