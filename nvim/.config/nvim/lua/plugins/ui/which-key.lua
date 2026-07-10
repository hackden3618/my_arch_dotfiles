--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/which-key.lua
--
-- Purpose:
--   Plugin specification for the Command Engine adapter.
--
-- Subsystem:  UI › Command Engine
-- Adapter:    which-key.nvim
--
-- Responsibilities:
--   • Declare which-key.nvim as a plugin dependency.
--   • Trigger on VeryLazy to avoid startup cost.
--   • Delegate all configuration to config/which-key.lua.
--
-- Notes:
--   which-key provides the keymap discoverability layer for the PDE.
--   Key group labels from all subsystems are registered here via the
--   config module. Each subsystem registers its own groups through
--   core.keymaps.group() which defers to which-key.
--------------------------------------------------------------------------------

return {

    "folke/which-key.nvim",

    event = "VeryLazy",

    opts = function()
        return require("plugins.ui.config.which-key")
    end,

}
