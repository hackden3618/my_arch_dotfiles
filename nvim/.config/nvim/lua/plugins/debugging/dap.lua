--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/debugging/dap.lua
--
-- Purpose:
--   Plugin specification for the Debug Engine.
--
-- Subsystem:  Debugging › Debug Engine
-- Adapters:   nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, mason-nvim-dap
--
-- Responsibilities:
--   • Declare the full DAP plugin stack.
--   • Lazy-load on the debug keymaps (zero startup cost).
--   • Wire together: UI setup → adapters → keymaps.
--
-- Notes:
--   INITIALIZATION ORDER:
--     1. dapui.setup()           — must run before event listeners
--     2. virtual-text.setup()    — depends on dap being initialized
--     3. adapters.setup()        — register codelldb + java adapters
--     4. keymaps.setup()         — bind all <leader>d keys
--
--   mason-nvim-dap is a separate spec entry within this file because
--   it must load alongside nvim-dap but has its own setup call.
--------------------------------------------------------------------------------

return {

    {
        "mfussenegger/nvim-dap",

        keys = {
            { "<leader>dc", desc = "Debug: Continue"          },
            { "<leader>db", desc = "Debug: Toggle Breakpoint" },
            { "<leader>du", desc = "Debug: Toggle UI"         },
        },

        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
        },

        config = function()

            -- Order matters — see Notes above
            require("plugins.debugging.config.ui").setup()
            require("plugins.debugging.config.adapters").setup()
            require("plugins.debugging.config.keymaps").setup()

        end,

    },

    {
        "jay-babu/mason-nvim-dap.nvim",

        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },

        event = "VeryLazy",

        opts = {
            ensure_installed   = {
                require("core.constants").DAP.CODELLDB,
                require("core.constants").DAP.JAVA_DEBUG,
                require("core.constants").DAP.JAVA_TEST,
            },
            automatic_installation = false,
            handlers = {},
        },

    },

}
