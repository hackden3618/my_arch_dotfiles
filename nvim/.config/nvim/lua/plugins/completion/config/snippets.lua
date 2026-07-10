--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/config/snippets.lua
--
-- Purpose:
--   Configuration for the Snippet Engine (LuaSnip).
--
-- Responsibilities:
--   • Load VSCode-format snippets from friendly-snippets.
--   • Register filetype extensions for composite file types.
--
-- Notes:
--   Filetype extensions allow one filetype to inherit snippets from another.
--   Examples:
--     javascriptreact → html  (JSX uses HTML snippet triggers like div, ul)
--     typescriptreact → html  (TSX same)
--     php             → html  (PHP templates embed HTML)
--
--   lazy_load() defers snippet loading until the filetype is first
--   entered, keeping startup time minimal.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local luasnip = require("luasnip")

    --------------------------------------------------------------------------
    -- Load VSCode Snippets
    --------------------------------------------------------------------------
    --
    -- Loads all snippets from friendly-snippets lazily (on demand
    -- when the relevant filetype is first opened).
    --------------------------------------------------------------------------

    require("luasnip.loaders.from_vscode").lazy_load()

    --------------------------------------------------------------------------
    -- Filetype Extensions
    --------------------------------------------------------------------------

    -- JSX inherits HTML snippets (div, ul, li, input, etc.)
    luasnip.filetype_extend("javascriptreact", { "html" })

    -- TSX inherits HTML snippets
    luasnip.filetype_extend("typescriptreact", { "html" })

    -- PHP templates embed HTML
    luasnip.filetype_extend("php", { "html" })

end

return M
