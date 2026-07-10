--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/config/autocmds.lua
--
-- Purpose:
--   Registers editor-wide automatic commands.
--
-- Responsibilities:
--   • Highlight on yank
--   • Restore cursor position
--   • Resize splits
--   • Plugin update notification (Lazy checker hook)
--
-- Notes:
--   Plugin-specific autocommands belong inside the plugin configuration.
--
--   LAZY CHECKER HOOK:
--   lazy.nvim's checker runs in the background and fires a User event
--   "LazyCheck" when it finishes scanning for updates. We hook into that
--   event here (rather than using checker.notify = true) so the notification
--   goes through nvim-notify for a styled popup instead of the raw echo line.
--   checker.notify remains false in lazy.lua to suppress the plain version.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Local Aliases
--------------------------------------------------------------------------------

local api = vim.api
local constants = require("core.constants")

--------------------------------------------------------------------------------
-- Autocommand Groups
--------------------------------------------------------------------------------

local general_group = api.nvim_create_augroup("General", { clear = true })

--------------------------------------------------------------------------------
-- Highlight Yank
--------------------------------------------------------------------------------
--
-- Briefly highlights text after it has been yanked.
--------------------------------------------------------------------------------

api.nvim_create_autocmd("TextYankPost", {

    group = general_group,

    desc = "Highlight yanked text",

    callback = function()

        vim.highlight.on_yank({

            higroup = "IncSearch",
            timeout = constants.TIME.YANK,

        })

    end,

})

--------------------------------------------------------------------------------
-- Restore Cursor Position
--------------------------------------------------------------------------------
--
-- Reopens files at the last cursor location.
--------------------------------------------------------------------------------

api.nvim_create_autocmd("BufReadPost", {

    group = general_group,

    desc = "Restore previous cursor position",

    callback = function(event)

        local mark = api.nvim_buf_get_mark(event.buf, '"')

        local line_count = api.nvim_buf_line_count(event.buf)

        if mark[1] > 0 and mark[1] <= line_count then
            pcall(api.nvim_win_set_cursor, 0, mark)
        end

    end,

})

--------------------------------------------------------------------------------
-- Equalize Splits
--------------------------------------------------------------------------------
--
-- Automatically resize all windows when Neovim itself is resized.
--------------------------------------------------------------------------------

api.nvim_create_autocmd("VimResized", {

    group = general_group,

    desc = "Resize splits equally",

    command = "tabdo wincmd =",

})

--------------------------------------------------------------------------------
-- Plugin Update Notifications
--------------------------------------------------------------------------------
--
-- Hooks into Lazy.nvim's background checker. When Lazy finishes scanning
-- and finds available updates, a styled nvim-notify popup is shown.
-- If everything is up to date, no notification is sent (no noise).
--
-- Depends on:
--   • lazy.nvim   — fires the "LazyCheck" User event
--   • nvim-notify — must be loaded before this event fires (priority 1100)
--------------------------------------------------------------------------------

api.nvim_create_autocmd("User", {

    group   = general_group,
    pattern = "LazyCheck",
    desc    = "Notify when Lazy.nvim finds plugin updates",

    callback = function()

        local lazy_status = require("lazy.status")

        if lazy_status.has_updates() then

            local logging = require("core.logging")
            local count   = lazy_status.updates()

            logging.info(
                count .. " plugin(s) have updates available.\nRun :Lazy update to apply.",
                "󰚰  Plugin Updates"
            )

        end

    end,

})
