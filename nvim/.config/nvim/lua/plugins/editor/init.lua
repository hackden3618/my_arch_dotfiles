--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/init.lua
--
-- Purpose:
--   Editor subsystem manifest.
--
-- Responsibilities:
--   • Register all Editor plugin specifications for Lazy.nvim.
--
-- Subsystems registered here:
--   • Syntax Engine    → treesitter   (highlighting, indent, text objects)
--   • Search Engine    → telescope    (fuzzy finder + ui-select)
--   • Explorer Engine  → nvim-tree    (file system sidebar)
--   • Comment Engine   → Comment.nvim (language-aware commenting)
--   • Surround         → nvim-surround (delimiter manipulation)
--   • Navigation       → harpoon2     (file bookmarks)
--   • Test Engine      → neotest      (multi-language test runner)
--
-- Notes:
--   Plugin specifications are intentionally separate from their
--   implementation details. No configuration logic lives here.
--------------------------------------------------------------------------------

return {

    require("plugins.editor.treesitter"),

    require("plugins.editor.telescope"),

    require("plugins.editor.nvim-tree"),

    require("plugins.editor.comment"),

    require("plugins.editor.surround"),

    require("plugins.editor.harpoon"),

    require("plugins.editor.neotest"),

}
