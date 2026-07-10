--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/debugging/config/ui.lua
--
-- Purpose:
--   DAP UI and virtual text configuration for the Debug Engine.
--
-- Responsibilities:
--   • Configure dapui layout and appearance.
--   • Configure nvim-dap-virtual-text for inline variable display.
--   • Wire dap event listeners to auto-open/close the UI.
--
-- Notes:
--   AUTO-OPEN / AUTO-CLOSE:
--   The DAP UI is wired to three events:
--     event_initialized → open UI (session started)
--     event_terminated  → close UI (session ended cleanly)
--     event_exited      → close UI (process exited)
--
--   This provides a VSCode-like behavior where the debug panels
--   appear automatically when debugging starts and disappear when done.
--
--   VIRTUAL TEXT:
--   nvim-dap-virtual-text shows variable values inline next to
--   their declaration, eliminating the need to check the variables
--   panel for simple inspections.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local dap     = require("dap")
    local dapui   = require("dapui")

    --------------------------------------------------------------------------
    -- DAP UI Setup
    --------------------------------------------------------------------------

    dapui.setup({

        icons = {
            expanded  = "",
            collapsed = "",
            current_frame = "",
        },

        mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            open   = "o",
            remove = "d",
            edit   = "e",
            repl   = "r",
            toggle = "t",
        },

        layouts = {
            {
                elements = {
                    { id = "scopes",      size = 0.35 },
                    { id = "breakpoints", size = 0.15 },
                    { id = "stacks",      size = 0.25 },
                    { id = "watches",     size = 0.25 },
                },
                size     = 40,
                position = "left",
            },
            {
                elements = {
                    { id = "repl",    size = 0.5 },
                    { id = "console", size = 0.5 },
                },
                size     = 12,
                position = "bottom",
            },
        },

        floating = {
            max_height  = 0.9,
            max_width   = 0.9,
            border      = "rounded",
            mappings    = { close = { "q", "<Esc>" } },
        },

    })

    --------------------------------------------------------------------------
    -- Virtual Text
    --------------------------------------------------------------------------

    require("nvim-dap-virtual-text").setup({
        enabled                 = true,
        enabled_commands        = true,
        highlight_changed_variables = true,
        highlight_new_as_changed    = false,
        show_stop_reason        = true,
        commented               = false,
        virt_text_pos           = "eol",
        all_frames              = false,
    })

    --------------------------------------------------------------------------
    -- Auto-open / Auto-close
    --------------------------------------------------------------------------

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

end

return M
