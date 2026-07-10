--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/init.lua
--
-- Purpose:
--   UI subsystem manifest.
--
-- Responsibilities:
--   • Register all UI plugin specifications for Lazy.nvim.
--
-- Subsystems registered here:
--   • Theme Engine     → catppuccin (visual identity)
--   • Command Engine   → which-key (keymap discoverability)
--   • Status Engine    → lualine   (statusline)
--   • Buffer Engine    → barbar    (buffer tabline)
--   • Command Completion → wilder  (enhanced : / ? completion)
--   • Notification Engine → nvim-notify (styled popup notifications)
--   • Diagnostics Panel → trouble.nvim (workspace diagnostics)
--   • TODO Engine      → todo-comments.nvim (project-wide tracking)
--
-- Notes:
--   Plugin specifications are intentionally separate from their
--   implementation details. No configuration logic lives here.
--------------------------------------------------------------------------------

return {

    require("plugins.ui.notify"),

    require("plugins.ui.catppuccin"),

    require("plugins.ui.which-key"),

    require("plugins.ui.lualine"),

    require("plugins.ui.barbar"),

    require("plugins.ui.wilder"),

    require("plugins.ui.trouble"),

    require("plugins.ui.todo-comments"),

    --------------------------------------------------------------------------
    -- Alternative Themes (optional, lazy-loaded)
    --------------------------------------------------------------------------

    require("plugins.ui.tokyonight"),

    require("plugins.ui.everforest"),

    require("plugins.ui.gruvbox"),

    require("plugins.ui.kanagawa"),

    require("plugins.ui.nord"),

    require("plugins.ui.onedarkpro"),

    require("plugins.ui.dracula"),

}
