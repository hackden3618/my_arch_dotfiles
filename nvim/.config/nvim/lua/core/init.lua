--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/init.lua
--
-- Purpose:
--   Central entry point for shared framework modules.
--
-- Notes:
--   This file intentionally performs no initialization. It exists to provide
--   a stable namespace for shared functionality.
--------------------------------------------------------------------------------

local M = {}

M.icons     = require("core.icons")
M.keymaps   = require("core.keymaps")
M.logging   = require("core.logging")
M.paths     = require("core.paths")
M.constants = require("core.constants")
M.helpers   = require("core.helpers")
M.theme     = require("core.theme")

return M
