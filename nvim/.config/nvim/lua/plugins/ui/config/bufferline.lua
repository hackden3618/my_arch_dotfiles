--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/bufferline.lua
--
-- Purpose:
--   Configuration for the Buffer Engine (barbar.nvim).
--
-- Responsibilities:
--   • Plugin visual configuration (icons, animation, diagnostics).
--   • Buffer navigation keymaps.
--   • Buffer management keymaps (close, pin, pick, reorder, sort).
--
-- Notes:
--   Keymaps use core.keymaps.n() to ensure consistent defaults.
--   The <leader>b namespace is owned entirely by this module.
--   Buffer navigation by position (1–9) is auto-generated.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local km = require("core.keymaps")

--------------------------------------------------------------------------------
-- Visual Options
--------------------------------------------------------------------------------

local opts = {

    animation  = true,
    auto_hide  = false,
    tabpages   = true,
    clickable  = true,

    icons = {
        buffer_index = true,
        buffer_number = false,
        button = "",
        diagnostics = {
            [vim.diagnostic.severity.ERROR] = { enabled = true },
            [vim.diagnostic.severity.WARN]  = { enabled = true },
            [vim.diagnostic.severity.INFO]  = { enabled = false },
            [vim.diagnostic.severity.HINT]  = { enabled = false },
        },
        gitsigns = {
            added    = { enabled = true, icon = "+" },
            changed  = { enabled = true, icon = "~" },
            deleted  = { enabled = true, icon = "-" },
        },
    },

}

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

local function setup_keymaps()

    --------------------------------------------------------------------------
    -- Navigation
    --------------------------------------------------------------------------

    km.n("<leader>bh", "<Cmd>BufferPrevious<CR>",   "Previous Buffer")
    km.n("<leader>bl", "<Cmd>BufferNext<CR>",        "Next Buffer")

    --------------------------------------------------------------------------
    -- Jump to Buffer by Position (1–9)
    --------------------------------------------------------------------------

    for i = 1, 9 do
        km.n(
            "<leader>b" .. i,
            "<Cmd>BufferGoto " .. i .. "<CR>",
            "Go to Buffer " .. i
        )
    end

    km.n("<leader>b0", "<Cmd>BufferLast<CR>", "Go to Last Buffer")

    --------------------------------------------------------------------------
    -- Reordering
    --------------------------------------------------------------------------

    km.n("<leader>b<", "<Cmd>BufferMovePrevious<CR>", "Move Buffer Left")
    km.n("<leader>b>", "<Cmd>BufferMoveNext<CR>",     "Move Buffer Right")

    --------------------------------------------------------------------------
    -- Actions
    --------------------------------------------------------------------------

    km.n("<leader>bc", "<Cmd>BufferClose<CR>",       "Close Buffer")
    km.n("<leader>bp", "<Cmd>BufferPin<CR>",          "Pin Buffer")
    km.n("<leader>bb", "<Cmd>BufferPick<CR>",         "Pick Buffer")
    km.n("<leader>bd", "<Cmd>BufferPickDelete<CR>",   "Delete Picked Buffer")

    --------------------------------------------------------------------------
    -- Sorting
    --------------------------------------------------------------------------

    km.n("<leader>bsn", "<Cmd>BufferOrderByBufferNumber<CR>", "Sort by Number")
    km.n("<leader>bsf", "<Cmd>BufferOrderByName<CR>",         "Sort by Name")
    km.n("<leader>bsd", "<Cmd>BufferOrderByDirectory<CR>",    "Sort by Directory")
    km.n("<leader>bsl", "<Cmd>BufferOrderByLanguage<CR>",     "Sort by Language")
    km.n("<leader>bsw", "<Cmd>BufferOrderByWindowNumber<CR>", "Sort by Window")

end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Initialize barbar and register all buffer keymaps.
--- Called from the plugin spec's config function.
function M.setup()
    require("barbar").setup(opts)
    setup_keymaps()
end

return M
