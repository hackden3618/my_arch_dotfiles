--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/icons.lua
--
-- Purpose:
--   Centralized icon registry for the entire PDE.
--
-- Responsibilities:
--   • Diagnostic icons (gutter + virtual text)
--   • Git status icons
--   • General UI chrome icons
--   • LSP action icons
--   • LSP completion kind icons
--   • Debug adapter icons
--
-- Notes:
--   Never hardcode icons elsewhere in the project. All icon references
--   must go through this module. This ensures a single point of change
--   if the user switches Nerd Font versions or icon sets.
--
--   Requires a Nerd Font to be active in your terminal emulator.
--   Recommended: JetBrainsMono Nerd Font or any Nerd Font v3.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------
--
-- Used by LSP diagnostic signs and virtual text.
--------------------------------------------------------------------------------

M.diagnostics = {
    Error = " ",
    Warn  = " ",
    Hint  = "󰌵 ",
    Info  = " ",
}

--------------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------------
--
-- Used by gitsigns and status line components.
--------------------------------------------------------------------------------

M.git = {
    added    = " ",
    modified = " ",
    removed  = " ",
    branch   = " ",
    diff     = "±",
    commit   = " ",
}

--------------------------------------------------------------------------------
-- UI Chrome
--------------------------------------------------------------------------------
--
-- General-purpose interface icons.
--------------------------------------------------------------------------------

M.ui = {
    search      = " ",
    folder      = " ",
    file        = "󰈔 ",
    terminal    = " ",
    gear        = " ",
    lightning   = " ",
    check       = " ",
    close       = "󰅖 ",
    arrow_right = " ",
    arrow_left  = " ",
    dot         = "● ",
    circle      = " ",
    lock        = " ",
    debug       = " ",
    run         = " ",
    package     = "󰏗 ",
}

--------------------------------------------------------------------------------
-- LSP Actions
--------------------------------------------------------------------------------
--
-- Used in status line components and keybinding descriptions.
--------------------------------------------------------------------------------

M.lsp = {
    reference  = "󰈇 ",
    rename     = "󰑕 ",
    code       = "󰅩 ",
    action     = " ",
    format     = "󰉶 ",
    signature  = " ",
}

--------------------------------------------------------------------------------
-- LSP Completion Kinds
--------------------------------------------------------------------------------
--
-- Used by nvim-cmp to decorate completion menu entries.
-- These map 1:1 to vim.lsp.protocol.CompletionItemKind values.
--------------------------------------------------------------------------------

M.kind = {
    Text          = "󰉿 ",
    Method        = "󰆧 ",
    Function      = "󰊕 ",
    Constructor   = " ",
    Field         = "󰜢 ",
    Variable      = "󰀫 ",
    Class         = "󰠱 ",
    Interface     = " ",
    Module        = " ",
    Property      = "󰜢 ",
    Unit          = "󰑭 ",
    Value         = "󰎠 ",
    Enum          = " ",
    Keyword       = "󰌋 ",
    Snippet       = " ",
    Color         = "󰏘 ",
    File          = "󰈙 ",
    Reference     = "󰈇 ",
    Folder        = "󰉋 ",
    EnumMember    = " ",
    Constant      = "󰏿 ",
    Struct        = "󰙅 ",
    Event         = " ",
    Operator      = "󰆕 ",
    TypeParameter = "󰊄 ",
    Codeium       = "󱙺 ",
}

--------------------------------------------------------------------------------
-- Debug Adapter Protocol
--------------------------------------------------------------------------------
--
-- Used by nvim-dap and dapui for visual breakpoint and session icons.
--------------------------------------------------------------------------------

M.dap = {
    breakpoint         = " ",
    breakpoint_cond    = "󰟃 ",
    breakpoint_reject  = " ",
    stopped            = " ",
    log_point          = "󱂅 ",
    pause              = " ",
    play               = " ",
    step_into          = " ",
    step_over          = " ",
    step_out           = " ",
    step_back          = " ",
    terminate          = " ",
}

return M
