--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/config/init.lua
--
-- Purpose:
--   Central entry point for the editor configuration.
--
-- Responsibilities:
--   • Load core editor options.
--   • Register global keymaps.
--   • Register custom user commands.
--   • Register autocommands.
--   • Bootstrap Lazy.nvim.
--
-- Notes:
--   This file intentionally contains no configuration logic.
--   Every subsystem should live in its own module.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Core Configuration
--------------------------------------------------------------------------------

require("config.options")
require("config.remap")
require("config.commands")
require("config.autocmds")

--------------------------------------------------------------------------------
-- Plugin Manager
--------------------------------------------------------------------------------

require("config.lazy")

--------------------------------------------------------------------------------
-- Theme System
--------------------------------------------------------------------------------

local theme = require("core.theme")
theme.setup_commands()
theme.init()
