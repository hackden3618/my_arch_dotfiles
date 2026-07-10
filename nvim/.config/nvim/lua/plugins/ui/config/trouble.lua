--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/trouble.lua
--
-- Purpose:
--   Configuration for the Diagnostics Panel (trouble.nvim).
--
-- Responsibilities:
--   • Define trouble.nvim appearance options.
--   • Register keymaps in the <leader>x namespace.
--
-- Notes:
--   KEYMAP NAMESPACE: <leader>x (x = eXamine / diagnostics)
--     <leader>xx → Workspace diagnostics (all files)
--     <leader>xb → Buffer diagnostics (current file only)
--     <leader>xs → Document symbols panel
--     <leader>xl → Location list
--     <leader>xq → Quickfix list
--
--   The panel integrates with the LSP configuration in
--   plugins/lsp/config/keymaps.lua. The ]d / [d navigation keymaps
--   provided by the LSP module continue to work as expected.
--------------------------------------------------------------------------------

local M = {}

M.keys = {
    { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>",
        desc = "Diagnostics: Workspace (Trouble)" },
    { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Diagnostics: Buffer (Trouble)" },
    { "<leader>xs", "<Cmd>Trouble symbols toggle focus=false<CR>",
        desc = "Diagnostics: Symbols (Trouble)" },
    { "<leader>xl", "<Cmd>Trouble loclist toggle<CR>",
        desc = "Diagnostics: Location List (Trouble)" },
    { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>",
        desc = "Diagnostics: Quickfix (Trouble)" },
}

M.opts = {
    auto_close      = true,
    auto_preview    = true,
    use_diagnostic_signs = true,
}

return M
