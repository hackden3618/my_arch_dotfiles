--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/todo-comments.lua
--
-- Purpose:
--   Plugin specification for the TODO Comment Engine adapter.
--
-- Subsystem:  UI › TODO Engine
-- Adapter:    todo-comments.nvim
--
-- Responsibilities:
--   • Declare todo-comments.nvim as a plugin.
--   • Lazy-load on BufReadPost.
--   • Register <leader>ft for Telescope TODO search.
--
-- Notes:
--   Highlights TODO, FIXME, HACK, NOTE, WARN, PERF, TEST tokens in all
--   filetypes. Uses Telescope for project-wide search via <leader>ft.
--   Integrates with trouble.nvim for the TODO panel view.
--------------------------------------------------------------------------------

return {

    "folke/todo-comments.nvim",

    event = { "BufReadPost", "BufNewFile" },

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    keys = {
        { "<leader>ft", "<Cmd>TodoTelescope<CR>",         desc = "Find: TODOs" },
        { "<leader>xt", "<Cmd>Trouble todo toggle<CR>",   desc = "Diagnostics: TODOs (Trouble)" },
    },

    opts = {
        signs      = true,
        sign_priority = 8,
        keywords = {
            FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = "󰅒 ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
            TEST = { icon = "⏲ ", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
        },
    },

}
