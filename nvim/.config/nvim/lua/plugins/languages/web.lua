--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/web.lua
--
-- Purpose:
--   Plugin specification for the Web Development tooling subsystem.
--
-- Subsystem:  Languages › Web
-- Adapter:    toggleterm.nvim
--
-- Responsibilities:
--   • Declare toggleterm.nvim for integrated terminal management.
--   • Load on VeryLazy since terminals aren't needed at startup.
--   • Delegate live-server and runner configuration to config/web.lua.
--
-- Notes:
--   toggleterm provides persistent, reusable terminal instances inside
--   Neovim. It is used here for:
--     • The live-server toggle (<leader>ls)
--     • C and Python quick runners (<leader>rc, <leader>rp)
--     • Global terminal toggle (<C-\>)
--------------------------------------------------------------------------------

return {

    "akinsho/toggleterm.nvim",

    version = "*",

    event = "VeryLazy",

    config = function()
        require("plugins.languages.config.web").setup()
    end,

}
