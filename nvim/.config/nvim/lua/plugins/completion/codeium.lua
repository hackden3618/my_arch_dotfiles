--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/codeium.lua
--
-- Purpose:
--   Plugin specification for the AI Engine adapter.
--
-- Subsystem:  Completion › AI Engine
-- Adapter:    codeium.nvim (Exafunction/codeium.nvim)
--
-- Responsibilities:
--   • Declare codeium.nvim and its required dependencies.
--   • Lazy-load on InsertEnter to avoid startup overhead.
--   • Initialize the Codeium AI completion source for nvim-cmp.
--
-- Notes:
--   codeium.nvim is the Lua-native Codeium plugin that integrates
--   directly with nvim-cmp as a completion source (source name: "codeium").
--   This is the correct integration point — not the older codeium.vim
--   which uses a separate virtual-text-only interface.
--
--   The codeium source is registered in the nvim-cmp source list inside
--   plugins/completion/config/completion.lua. Both plugins must load
--   correctly for AI suggestions to appear in the completion menu.
--
--   Authentication: Run :Codeium Auth on first use to link your account.
--------------------------------------------------------------------------------

return {

    "Exafunction/codeium.nvim",

    event = "InsertEnter",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },

    config = function()
        require("codeium").setup({})
    end,

}
