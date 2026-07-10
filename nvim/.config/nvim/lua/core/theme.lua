-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme.lua
--
-- Purpose:
--   Entry point for the Theme Engine. Delegates to core/theme/init.lua.
--
-- Responsibilities:
--   • Redirect all theme API calls to the implementation module.
--
-- Notes:
--   This file exists so that consumers can require("core.theme") without
--   knowing whether the implementation lives in a module or a directory.
--   The directory module pattern (core/theme/init.lua) is preferred for
--   this subsystem because it has grown beyond a single file.
-------------------------------------------------------------------------------

return require("core.theme.init")
