--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/neotest.lua
--
-- Purpose:
--   Plugin specification for the Test Engine adapter.
--
-- Subsystem:  Editor › Test Engine
-- Adapter:    neotest
--
-- Responsibilities:
--   • Declare neotest and all language adapters as plugins.
--   • Lazy-load on keymap trigger.
--   • Delegate all configuration to config/neotest.lua.
--
-- Notes:
--   ADAPTERS INCLUDED:
--     neotest-jest    → JavaScript / TypeScript (Jest, Vitest)
--     neotest-python  → Python (pytest, unittest)
--
--   Java test running is handled by JDTLS + java-test bundle
--   (already configured in plugins/languages/config/java.lua).
--   Go test running uses the standard `go test` via DAP.
--
--   KEYMAP NAMESPACE: <leader>T (T = Testing)
--     <leader>Tn → Run nearest test
--     <leader>Tf → Run current file
--     <leader>Ts → Toggle summary panel
--     <leader>To → Show test output
--     <leader>Tq → Stop test run
--------------------------------------------------------------------------------

return {

    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        -- Adapters
        "nvim-neotest/neotest-jest",
        "nvim-neotest/neotest-python",
    },

    keys = function()
        return require("plugins.editor.config.neotest").keys
    end,

    config = function()
        require("plugins.editor.config.neotest").setup()
    end,

}
