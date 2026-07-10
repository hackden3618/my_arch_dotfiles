-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme/system.lua
--
-- Purpose:
--   Generate a terminal-adaptive "system" theme.
--
-- Responsibilities:
--   • Detect terminal background (dark/light).
--   • Produce a theme definition where every highlight group inherits
--     the terminal's default colors (fg = none, bg = none).
--
-- Notes:
--   This mirrors opencode's "system" theme which uses ANSI terminal
--   colors and defers to terminal defaults wherever possible.
--   All highlight groups are reset to NONE so Neovim inherits the
--   terminal emulator's native color scheme.
--
--   ARCHITECTURE DECISION — Terminal-native rendering:
--   Unlike Neovim colorscheme plugins which assign explicit colors,
--   the system theme sets every group to fg=none / bg=none. This
--   makes Neovim invisible — the terminal's own colors show through.
--   The trade-off is that syntax highlighting is minimal (only
--   inheriting from the terminal's ANSI defaults), but the result
--   always matches the user's terminal theme perfectly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

--- Neutral highlight groups that should always use terminal defaults.
--- Every syntax group is included so the theme completely clears any
--- previous colorscheme.
local TERMINAL_DEFAULTS = {
    -- Editor chrome
    Normal          = { fg = "none", bg = "none" },
    NormalFloat     = { fg = "none", bg = "none" },
    ColorColumn     = { bg = "none" },
    Conceal         = { fg = "none" },
    Cursor          = { fg = "none", bg = "none" },
    CursorColumn    = { bg = "none" },
    CursorLine      = { bg = "none" },
    CursorLineNr    = { fg = "none" },
    DiffAdd         = { fg = "none", bg = "none" },
    DiffChange      = { fg = "none", bg = "none" },
    DiffDelete      = { fg = "none", bg = "none" },
    DiffText        = { fg = "none", bg = "none" },
    Directory       = { fg = "none" },
    EndOfBuffer     = { fg = "none" },
    ErrorMsg        = { fg = "none" },
    FoldColumn      = { fg = "none", bg = "none" },
    Folded          = { fg = "none", bg = "none" },
    IncSearch       = { fg = "none", bg = "none" },
    LineNr          = { fg = "none" },
    MatchParen      = { fg = "none", style = "bold" },
    ModeMsg         = { fg = "none" },
    MoreMsg         = { fg = "none" },
    NonText         = { fg = "none" },
    Pmenu           = { fg = "none", bg = "none" },
    PmenuSel        = { fg = "none", bg = "none" },
    PmenuSbar       = { bg = "none" },
    PmenuThumb      = { bg = "none" },
    Question        = { fg = "none" },
    Search          = { fg = "none", bg = "none" },
    SignColumn      = { fg = "none", bg = "none" },
    SpecialKey      = { fg = "none" },
    SpellBad        = { fg = "none", style = "undercurl" },
    SpellCap        = { fg = "none", style = "undercurl" },
    SpellLocal      = { fg = "none", style = "undercurl" },
    SpellRare       = { fg = "none", style = "undercurl" },
    StatusLine      = { fg = "none", bg = "none" },
    StatusLineNC    = { fg = "none", bg = "none" },
    TabLine         = { fg = "none", bg = "none" },
    TabLineFill     = { fg = "none", bg = "none" },
    TabLineSel      = { fg = "none", bg = "none" },
    Title           = { fg = "none" },
    VertSplit       = { fg = "none", bg = "none" },
    Visual          = { bg = "none" },
    VisualNOS       = { bg = "none" },
    WarningMsg      = { fg = "none" },
    WildMenu        = { fg = "none", bg = "none" },

    -- Syntax groups
    Comment         = { fg = "none" },
    Constant        = { fg = "none" },
    String          = { fg = "none" },
    Character       = { fg = "none" },
    Number          = { fg = "none" },
    Boolean         = { fg = "none" },
    Float           = { fg = "none" },
    Identifier      = { fg = "none" },
    Function        = { fg = "none" },
    Statement       = { fg = "none" },
    Conditional     = { fg = "none" },
    Repeat          = { fg = "none" },
    Label           = { fg = "none" },
    Operator        = { fg = "none" },
    Keyword         = { fg = "none" },
    Exception       = { fg = "none" },
    PreProc         = { fg = "none" },
    Include         = { fg = "none" },
    Define          = { fg = "none" },
    Macro           = { fg = "none" },
    PreCondit       = { fg = "none" },
    Type            = { fg = "none" },
    StorageClass    = { fg = "none" },
    Structure       = { fg = "none" },
    Typedef         = { fg = "none" },
    Special         = { fg = "none" },
    SpecialChar     = { fg = "none" },
    Tag             = { fg = "none" },
    Delimiter       = { fg = "none" },
    SpecialComment  = { fg = "none" },
    Debug           = { fg = "none" },
    Underlined      = { style = "underline" },
    Ignore          = { fg = "none" },
    Error           = { fg = "none" },
    Todo            = { fg = "none", bg = "none" },

    -- LSP
    LspReferenceText  = { bg = "none" },
    LspReferenceRead  = { bg = "none" },
    LspReferenceWrite = { bg = "none" },
    DiagnosticHint    = { fg = "none" },
    DiagnosticInfo    = { fg = "none" },
    DiagnosticWarn    = { fg = "none" },
    DiagnosticError   = { fg = "none" },
    DiagnosticUnderlineHint  = { style = "undercurl" },
    DiagnosticUnderlineInfo  = { style = "undercurl" },
    DiagnosticUnderlineWarn  = { style = "undercurl" },
    DiagnosticUnderlineError = { style = "undercurl" },
}

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local M = {}

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Generate the system theme definition.
--- Detects terminal background (dark/light) and returns a complete
--- theme table with all highlight groups set to terminal defaults.
---
--- @return table
function M.generate()
    local bg = vim.o.background or "dark"

    return {
        name        = "system",
        label       = "System (Terminal Adaptive)",
        type        = bg,
        colorscheme = nil,
        lualine     = "auto",
        defs        = {},
        highlights  = TERMINAL_DEFAULTS,
    }
end

return M
