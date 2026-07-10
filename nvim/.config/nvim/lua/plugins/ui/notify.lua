--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/notify.lua
--
-- Purpose:
--   Plugin specification for the Notification Engine adapter.
--
-- Subsystem:  UI › Notification Engine
-- Adapter:    nvim-notify
--
-- Responsibilities:
--   • Declare nvim-notify as a plugin.
--   • Load at startup (priority 1100) so it replaces vim.notify before
--     any other plugin can emit notifications.
--   • Delegate all configuration to config/notify.lua.
--
-- Notes:
--   nvim-notify replaces vim.notify globally. Because core.logging
--   wraps vim.notify, all PDE subsystem notifications automatically
--   gain popup styling, icon support, and history without code changes.
--
--   Priority 1100 ensures notify loads before catppuccin (1000) so
--   any theme-load notifications are already styled.
--------------------------------------------------------------------------------

return {

    "rcarriga/nvim-notify",

    lazy     = false,
    priority = 1100,

    config = function()
        require("plugins.ui.config.notify").setup()
    end,

}
