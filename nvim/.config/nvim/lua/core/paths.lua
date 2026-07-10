--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/paths.lua
--
-- Purpose:
--   Centralized filesystem path registry for the PDE.
--
-- Responsibilities:
--   • Expose Neovim standard path directories (config, data, cache, state).
--   • Pre-compute frequently used derived paths (lazy, undo, backup, swap).
--
-- Notes:
--   All subsystems that need a filesystem path should import this module
--   rather than calling vim.fn.stdpath() inline. This ensures that any
--   future path migration only requires changes in one place.
--
--   Paths are computed at module-load time (not lazily) because they are
--   pure functions of the Neovim environment and never change during a session.
--------------------------------------------------------------------------------

local M = {}

local fn = vim.fn

--------------------------------------------------------------------------------
-- Neovim Directories
--------------------------------------------------------------------------------

M.config = fn.stdpath("config")
M.data   = fn.stdpath("data")
M.cache  = fn.stdpath("cache")
M.state  = fn.stdpath("state")

--------------------------------------------------------------------------------
-- Frequently Used Paths
--------------------------------------------------------------------------------

M.lazy = M.data .. "/lazy"

M.undo = M.state .. "/undo"

M.backup = M.state .. "/backup"

M.swap = M.state .. "/swap"

return M
