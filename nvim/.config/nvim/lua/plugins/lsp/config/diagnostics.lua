--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/lsp/config/diagnostics.lua
--
-- Purpose:
--   Diagnostic UI configuration for the Diagnostics Engine.
--
-- Responsibilities:
--   • Configure diagnostic virtual text, signs, and float windows.
--   • Register gutter sign symbols using core.icons.
--
-- Notes:
--   Diagnostic sign names changed in Neovim 0.10+. The new API uses
--   vim.diagnostic.config({ signs = { text = { ... } } }) instead of
--   vim.fn.sign_define(). This implementation uses the modern API with
--   a compatibility fallback for Neovim < 0.10.
--
--   virtual_text:
--     prefix   → the marker shown before the diagnostic message
--     source   → "if_many" shows the LSP name only when multiple LSPs attach
--
--   float:
--     source   → "always" shows the LSP name in the float window
--     border   → uses the PDE standard rounded border
--------------------------------------------------------------------------------

local M = {}

local icons     = require("core.icons")
local constants = require("core.constants")

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Apply diagnostic UI configuration.
--- Called once from the LSP plugin config function.
function M.setup()

    --------------------------------------------------------------------------
    -- Diagnostic Config
    --------------------------------------------------------------------------

    vim.diagnostic.config({

        virtual_text = {
            prefix = icons.ui.dot,
            source = "if_many",
        },

        float = {
            source  = "always",
            border  = constants.UI.BORDER,
            header  = "",
            prefix  = "",
        },

        signs           = true,
        underline       = true,
        update_in_insert = false,
        severity_sort   = true,

    })

    --------------------------------------------------------------------------
    -- Gutter Signs
    --------------------------------------------------------------------------
    --
    -- Modern API (Neovim 0.10+): use the signs.text table.
    -- Legacy fallback (Neovim < 0.10): use vim.fn.sign_define().
    --------------------------------------------------------------------------

    if vim.fn.has("nvim-0.10") == 1 then

        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
                    [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warn,
                    [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
                    [vim.diagnostic.severity.INFO]  = icons.diagnostics.Info,
                },
            },
        })

    else

        local sign_map = {
            { name = "DiagnosticSignError", text = icons.diagnostics.Error },
            { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warn  },
            { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint  },
            { name = "DiagnosticSignInfo",  text = icons.diagnostics.Info  },
        }

        for _, sign in ipairs(sign_map) do
            vim.fn.sign_define(sign.name, {
                texthl = sign.name,
                text   = sign.text,
                numhl  = "",
            })
        end

    end

end

return M
