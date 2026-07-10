--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/debugging/config/keymaps.lua
--
-- Purpose:
--   Keymap definitions for the Debug Engine.
--
-- Responsibilities:
--   • DAP session control keymaps (<leader>d namespace).
--   • DAP UI toggle keymap.
--
-- Notes:
--   All debug keymaps are in the <leader>d namespace, consistent with
--   the which-key group defined in plugins/ui/config/which-key.lua.
--
--   Keymaps are intentionally simple function wrappers — each keymap
--   directly calls the appropriate dap or dapui function.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local dap   = require("dap")
    local dapui = require("dapui")
    local km    = require("core.keymaps")

    --------------------------------------------------------------------------
    -- Session Control
    --------------------------------------------------------------------------

    km.n("<leader>dc", dap.continue,          "Debug: Continue")
    km.n("<leader>db", dap.toggle_breakpoint, "Debug: Toggle Breakpoint")
    km.n("<leader>di", dap.step_into,         "Debug: Step Into")
    km.n("<leader>do", dap.step_over,         "Debug: Step Over")
    km.n("<leader>dO", dap.step_out,          "Debug: Step Out")
    km.n("<leader>dt", dap.terminate,         "Debug: Terminate")
    km.n("<leader>dr", dap.repl.open,         "Debug: Open REPL")

    --------------------------------------------------------------------------
    -- Breakpoint Management
    --------------------------------------------------------------------------

    km.n("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, "Debug: Conditional Breakpoint")

    km.n("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, "Debug: Log Point")

    --------------------------------------------------------------------------
    -- UI
    --------------------------------------------------------------------------

    km.n("<leader>du", dapui.toggle, "Debug: Toggle UI")

    km.n("<leader>de", function()
        dapui.eval(nil, { enter = true })
    end, "Debug: Evaluate Expression")

end

return M
