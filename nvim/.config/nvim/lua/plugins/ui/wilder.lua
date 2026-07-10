--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/wilder.lua
--
-- Purpose:
--   Plugin specification for the Command Completion adapter.
--
-- Subsystem:  UI › Command Engine (completion layer)
-- Adapter:    wilder.nvim
--
-- Responsibilities:
--   • Declare wilder.nvim as a plugin dependency.
--   • Load on the cmdline events that trigger command-mode entry.
--   • Delegate all configuration to config/wilder.lua.
--
-- Notes:
--   wilder.nvim enhances Neovim's : / ? command-line with a popup menu
--   showing fuzzy-matched completions.
--
--   This configuration uses the PURE LUA pipeline only — no Python
--   (pynvim) dependency is required. The lua_fzy_filter() is used
--   instead of vim_fuzzy_filter() to eliminate the Python requirement
--   while retaining fuzzy matching capability.
--
--   Loading is deferred to CmdlineEnter to ensure zero startup overhead.
--------------------------------------------------------------------------------

return {

    "gelguy/wilder.nvim",

    event = "CmdlineEnter",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "romgrk/fzy-lua-native",
    },

    config = function()
        require("plugins.ui.config.wilder").setup()
    end,

}
