--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/lsp/config/keymaps.lua
--
-- Purpose:
--   LSP on-attach keymap definitions for the Language Intelligence Engine.
--
-- Responsibilities:
--   • Register buffer-local LSP keymaps when an LSP attaches.
--   • Provide go-to navigation, documentation, and code action bindings.
--   • Register which-key group labels for the <leader>c namespace.
--
-- Notes:
--   All keymaps here are BUFFER-LOCAL (scoped to the buffer where LSP
--   attached). This prevents them from interfering with non-LSP buffers.
--
--   KEYMAP PHILOSOPHY:
--     gd / gD / gi / gr   → Navigation (go-to prefix, vim convention)
--     K                   → Hover docs (universal vim convention)
--     <leader>c*          → Code actions (c = code namespace)
--     gl / [d / ]d        → Diagnostic navigation
--     <leader>q           → Quickfix list
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Register all LSP keymaps for the current buffer.
--- Called from the LspAttach autocommand.
---
--- @param buf integer  Buffer number from the LspAttach event.
function M.on_attach(buf)

    local km = require("core.keymaps")

    local opts = { buffer = buf }

    --------------------------------------------------------------------------
    -- Navigation
    --------------------------------------------------------------------------

    km.n("gd", vim.lsp.buf.definition,     "Go to Definition",     opts)
    km.n("gD", vim.lsp.buf.declaration,    "Go to Declaration",    opts)
    km.n("gi", vim.lsp.buf.implementation, "Go to Implementation", opts)
    km.n("gr", vim.lsp.buf.references,     "Go to References",     opts)
    km.n("K",  vim.lsp.buf.hover,          "Hover Documentation",  opts)
    km.n("gK", vim.lsp.buf.signature_help, "Signature Help",       opts)

    --------------------------------------------------------------------------
    -- Code Actions
    --------------------------------------------------------------------------

    km.n("<leader>cr", vim.lsp.buf.rename, "Rename Symbol", opts)

    km.n("<leader>ca", vim.lsp.buf.code_action, "Code Actions", opts)
    km.x("<leader>ca", vim.lsp.buf.code_action, "Code Actions", opts)

    km.n("<leader>cf", function()
        vim.lsp.buf.format({ async = true })
    end, "Format File", opts)

    --------------------------------------------------------------------------
    -- Diagnostics
    --------------------------------------------------------------------------

    km.n("gl",        vim.diagnostic.open_float, "Show Diagnostic Float", opts)
    km.n("[d",        vim.diagnostic.goto_prev,  "Previous Diagnostic",   opts)
    km.n("]d",        vim.diagnostic.goto_next,  "Next Diagnostic",       opts)
    km.n("<leader>q", vim.diagnostic.setloclist, "Diagnostics to Loclist", opts)

end

return M
