--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/notify.lua
--
-- Purpose:
--   Configuration for the Notification Engine (nvim-notify).
--
-- Responsibilities:
--   • Configure notification appearance (style, animation, timeout).
--   • Replace vim.notify globally so all subsystems gain styled popups.
--
-- Notes:
--   The timeout uses constants.TIME.NOTIFICATION for single-source-of-truth.
--   background_colour must be set explicitly when using transparent terminals
--   to prevent rendering artifacts.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local notify    = require("notify")
    local constants = require("core.constants")

    notify.setup({
        background_colour = "#1e1e2e",    -- Catppuccin Mocha base
        render            = "wrapped-compact",
        stages            = "slide",
        timeout           = constants.TIME.NOTIFICATION,
        max_width         = 60,
        icons = {
            ERROR = " ",
            WARN  = " ",
            INFO  = " ",
            DEBUG = " ",
            TRACE = "✎ ",
        },
    })

    -- Replace vim.notify globally
    vim.notify = notify

end

return M
