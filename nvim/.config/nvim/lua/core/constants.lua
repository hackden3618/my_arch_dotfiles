--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/constants.lua
--
-- Purpose:
--   Centralized constants registry for the entire PDE.
--
-- Responsibilities:
--   • UI dimension and style constants
--   • Timing constants
--   • Treesitter file-size limits
--   • LSP server name constants
--   • DAP adapter name constants
--
-- Notes:
--   Never hardcode string literals that appear in more than one place.
--   All magic values must be named here. This is the single source of
--   truth for configuration values shared across subsystems.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- User Interface
--------------------------------------------------------------------------------

M.UI = {

    --- Window border style used across all floating windows.
    BORDER = "rounded",

    --- Default floating window width as a fraction of the screen.
    FLOAT_WIDTH = 0.90,

    --- Default floating window height as a fraction of the screen.
    FLOAT_HEIGHT = 0.85,

}

--------------------------------------------------------------------------------
-- Timing
--------------------------------------------------------------------------------

M.TIME = {

    --- Default notification display duration in milliseconds.
    NOTIFICATION = 3000,

    --- Duration of the yank highlight in milliseconds.
    YANK = 200,

}

--------------------------------------------------------------------------------
-- Treesitter
--------------------------------------------------------------------------------

M.TS = {

    --- Files larger than this (in bytes) skip Treesitter parsing.
    --- Prevents slowdowns on huge generated or minified files.
    MAX_FILE_SIZE = 1024 * 100,

}

--------------------------------------------------------------------------------
-- LSP Servers
--------------------------------------------------------------------------------
--
-- Canonical server names as recognized by mason-lspconfig.
-- Reference: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
--------------------------------------------------------------------------------

M.LSP = {

    -- General
    LUA         = "lua_ls",

    -- JVM
    JAVA        = "jdtls",

    -- C / C++
    CLANGD      = "clangd",

    -- Web — Core
    TYPESCRIPT  = "ts_ls",
    HTML        = "html",
    CSS         = "cssls",
    TAILWIND    = "tailwindcss",
    EMMET       = "emmet_ls",

    -- Data / Config
    JSON        = "jsonls",

    -- Go

    -- Rust
    RUST        = "rust_analyzer",

    -- Python
    PYTHON      = "pyright",

}

--------------------------------------------------------------------------------
-- DAP Adapters
--------------------------------------------------------------------------------
--
-- Canonical adapter names as recognized by mason-nvim-dap.
-- Reference: https://github.com/jay-babu/mason-nvim-dap.nvim
--------------------------------------------------------------------------------

M.DAP = {

    CODELLDB           = "codelldb",
    JAVA_DEBUG         = "java-debug-adapter",
    JAVA_TEST          = "java-test",

}

return M
