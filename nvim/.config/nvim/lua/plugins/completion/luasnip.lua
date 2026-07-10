--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/luasnip.lua
--
-- Purpose:
--   Plugin specification for the Snippet Engine adapter.
--
-- Subsystem:  Completion › Snippet Engine
-- Adapter:    LuaSnip
--
-- Responsibilities:
--   • Declare LuaSnip and friendly-snippets as dependencies.
--   • Build jsregexp for advanced snippet transformations.
--   • Delegate snippet loading configuration to config/snippets.lua.
--
-- Notes:
--   friendly-snippets provides a community-maintained VSCode-format
--   snippet library for 40+ languages, loaded lazily via lazy_load().
--------------------------------------------------------------------------------

return {

    "L3MON4D3/LuaSnip",

    version = "*",

    build = "make install_jsregexp",

    event = "InsertEnter",

    dependencies = {
        "rafamadriz/friendly-snippets",
    },

    config = function()
        require("plugins.completion.config.snippets").setup()
    end,

}
