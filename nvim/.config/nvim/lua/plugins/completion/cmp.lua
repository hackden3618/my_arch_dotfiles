--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/cmp.lua
--
-- Purpose:
--   Plugin specification for the Completion Engine adapter.
--
-- Subsystem:  Completion › Completion Engine
-- Adapter:    nvim-cmp
--
-- Responsibilities:
--   • Declare nvim-cmp and all completion source plugins.
--   • Lazy-load on InsertEnter and CmdlineEnter.
--   • Delegate all completion behavior to config/completion.lua.
--
-- Notes:
--   Source priority order (highest to lowest):
--     1. nvim_lsp   — Language server completions
--     2. luasnip    — Snippet expansions
--     3. codeium    — AI suggestions
--     4. buffer     — Words from open buffers
--     5. path       — File system paths
--
--   cmp-nvim-lsp is a critical dependency — it must be loaded before
--   LSP attaches to provide LSP-aware completion capabilities.
--------------------------------------------------------------------------------

return {

    "hrsh7th/nvim-cmp",

    event = { "InsertEnter", "CmdlineEnter" },

    dependencies = {
        -- LSP source
        "hrsh7th/cmp-nvim-lsp",

        -- Buffer + path sources
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",

        -- Snippet engine + cmp bridge
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",

        -- AI source
        "Exafunction/codeium.nvim",

        -- Autopairs integration
        "windwp/nvim-autopairs",
    },

    config = function()
        require("plugins.completion.config.completion").setup()
    end,

}
