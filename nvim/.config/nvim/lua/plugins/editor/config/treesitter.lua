--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/treesitter.lua
--
-- Purpose:
--   Configuration for the Syntax Engine (nvim-treesitter).
--
-- Responsibilities:
--   • Declare the set of parsers to automatically install.
--   • Enable highlight, indent, and incremental selection modules.
--
-- Notes:
--   PARSER CATALOG — languages supported by this PDE:
--     Core:       lua, vim, vimdoc, query
--     JVM:        java
--     Systems:    c, cpp, rust
--     Scripting:  python
--     Go:         go, gomod, gosum, gowork
--     Web:        html, css, javascript, typescript, tsx, jsx, jsdoc
--     Data:       json, yaml, toml, markdown, markdown_inline
--     Config:     prisma  ← Prisma ORM schema support
--
--   Prisma parser: provides full syntax highlighting for .prisma schema
--   files. Combined with prisma/vim-prisma (filetype detection), this
--   gives complete editor support for Prisma ORM development.
--
--   MAX_FILE_SIZE guard: files larger than 100 KB skip Treesitter
--   parsing to prevent slowdowns on generated or minified files.
--------------------------------------------------------------------------------

local constants = require("core.constants")

return {

    --------------------------------------------------------------------------------
    -- Parsers
    --------------------------------------------------------------------------------

    ensure_installed = {},
    -- ensure_installed = {
    --
    --     -- Neovim / Editor Config
    --     "lua",
    --     "vim",
    --     "vimdoc",
    --     "query",
    --
    --     -- JVM
    --     "java",
    --
    --     -- Systems
    --     "c",
    --     "cpp",
    --     "rust",
    --
    --     -- Scripting
    --     "python",
    --
    --     -- Go
    --     "go",
    --     "gomod",
    --     "gosum",
    --     "gowork",
    --
    --     -- Web — Core
    --     "html",
    --     "css",
    --     "javascript",
    --     "typescript",
    --     "tsx",
    --     "jsx",
    --     "jsdoc",
    --
    --     -- Web — ORM
    --     "prisma",
    --
    --     -- Data / Config
    --     "json",
    --     "yaml",
    --     "toml",
    --     "markdown",
    --     "markdown_inline",
    --
    -- },

    --------------------------------------------------------------------------------
    -- Modules
    --------------------------------------------------------------------------------

    highlight = {
        enable = true,

        -- Skip very large files to avoid freezing
        disable = function(_, buf)
            local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
            return size > constants.TS.MAX_FILE_SIZE
        end,
    },

    indent = {
        enable = true,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental  = "<M-space>",
        },
    },

}
