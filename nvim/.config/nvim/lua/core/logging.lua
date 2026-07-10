--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/logging.lua
--
-- Purpose:
--   PDE standard library for user notifications.
--
-- Responsibilities:
--   • Provide typed wrappers for all vim.notify log levels.
--   • Provide an optional title parameter for all levels.
--   • Provide a debug level that is silenced unless DEBUG mode is active.
--
-- Notes:
--   Plugins and subsystems should always use this module instead of
--   calling vim.notify() directly. If a richer notification backend
--   (e.g. nvim-notify) is installed, it will automatically pick up
--   the title field.
--
--   Debug output is controlled via vim.g.pde_debug. Set it to true
--   in your config to enable debug messages during development.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local notify = vim.notify
local levels  = vim.log.levels

--------------------------------------------------------------------------------
-- Internals
--------------------------------------------------------------------------------

--- Build the options table passed to vim.notify.
---
--- @param title string|nil  Optional popup title.
--- @return table|nil
local function build_opts(title)
    if title then
        return { title = title }
    end
    return nil
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Send an informational notification.
---
--- @param message string  The notification body.
--- @param title   string|nil  Optional popup title.
function M.info(message, title)
    notify(message, levels.INFO, build_opts(title))
end

--- Send a warning notification.
---
--- @param message string
--- @param title   string|nil
function M.warn(message, title)
    notify(message, levels.WARN, build_opts(title))
end

--- Send an error notification.
---
--- @param message string
--- @param title   string|nil
function M.error(message, title)
    notify(message, levels.ERROR, build_opts(title))
end

--- Send a success notification (INFO level with "Success" title).
---
--- @param message string
--- @param title   string|nil  Overrides default "Success" title if provided.
function M.success(message, title)
    notify(message, levels.INFO, build_opts(title or "Success"))
end

--- Send a debug notification.
---
--- Only emits output when vim.g.pde_debug == true.
--- Use during active development to trace behavior without
--- leaving noise in the production config.
---
--- @param message string
--- @param title   string|nil
function M.debug(message, title)
    if vim.g.pde_debug then
        notify("[DEBUG] " .. message, levels.DEBUG, build_opts(title or "PDE Debug"))
    end
end

return M
