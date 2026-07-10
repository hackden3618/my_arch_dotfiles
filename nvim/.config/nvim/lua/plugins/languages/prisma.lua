--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/prisma.lua
--
-- Purpose:
--   Plugin specification for Prisma ORM schema language support.
--
-- Subsystem:  Languages › Prisma
-- Adapter:    vim-prisma (prisma/vim-prisma)
--
-- Responsibilities:
--   • Provide filetype detection for .prisma schema files.
--   • Enable syntax highlighting via vim-prisma (regex-based fallback).
--   • Treesitter-based highlighting is the primary source — see
--     plugins/editor/config/treesitter.lua where "prisma" is in
--     ensure_installed.
--
-- Notes:
--   TWO-LAYER PRISMA SUPPORT:
--
--   Layer 1 — Filetype detection (vim-prisma):
--     vim-prisma registers the "prisma" filetype for *.prisma files.
--     Without this, Neovim treats .prisma as plain text.
--
--   Layer 2 — Syntax highlighting (treesitter):
--     The treesitter "prisma" parser (ensure_installed in treesitter.lua)
--     provides semantic, tree-based syntax highlighting that supersedes
--     vim-prisma's regex-based highlighting.
--
--   Together they deliver complete Prisma schema support:
--     ✓ Filetype detection and recognition
--     ✓ Accurate syntax highlighting (model, field, type, enum, etc.)
--     ✓ LSP-compatible (if prisma-language-server is installed via Mason)
--     ✓ Comment toggling (Comment.nvim recognizes prisma filetype)
--     ✓ Treesitter text objects and selection
--
--   PRISMA LSP (optional):
--   Install via Mason: :MasonInstall prisma-language-server
--   Then add to plugins/lsp/config/servers.lua ensure_installed list.
--------------------------------------------------------------------------------

return {

    "prisma/vim-prisma",

    ft = "prisma",

    -- vim-prisma requires no setup call — filetype registration
    -- is handled via the plugin's ftdetect/ directory automatically.

}
