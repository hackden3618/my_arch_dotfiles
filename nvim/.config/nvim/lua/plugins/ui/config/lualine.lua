--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/lualine.lua
--
-- Purpose:
--   Configuration for the Status Engine (lualine.nvim).
--
-- Responsibilities:
--   • Define statusline theme and section layout.
--   • Express visual identity through section composition.
--   • Show: mode, git branch, diagnostics, LSP name, filetype, position.
--   • Dynamically resolve the theme name from core.theme so that
--     switching themes also updates the statusline.
--
-- Notes:
--   Section naming:
--     lualine_a: far left (mode)
--     lualine_b: left (git, branch)
--     lualine_c: center-left (filename, diff)
--     lualine_x: center-right (diagnostics, lsp, filetype)
--     lualine_y: right (progress)
--     lualine_z: far right (location)
--
--   get_config() is called both at startup (by the plugin spec) and
--   on theme switch (by core.theme.set()). This ensures the statusline
--   always matches the active theme.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Show the active LSP server name for the current buffer.
local function lsp_name()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        return ""
    end
    return "  " .. clients[1].name
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Build and return the complete lualine configuration table.
--- The theme is resolved from core.theme so it tracks the active theme.
---
--- @return table
function M.get_config()

    local icons = require("core.icons")
    local theme = require("core.theme")

    return {

        options = {
            theme                = theme.lualine_theme(),
            globalstatus         = true,
            section_separators   = { left = "", right = "" },
            component_separators = { left = "│", right = "│" },
        },

        sections = {

            lualine_a = {
                { "mode", icon = icons.ui.lightning },
            },

            lualine_b = {
                { "branch", icon = icons.git.branch },
            },

            lualine_c = {
                {
                    "filename",
                    path = 1,
                    symbols = {
                        modified  = " " .. icons.git.modified,
                        readonly  = " " .. icons.ui.lock,
                        unnamed   = "[No Name]",
                        newfile   = " [New]",
                    },
                },
                {
                    "diff",
                    symbols = {
                        added    = icons.git.added,
                        modified = icons.git.modified,
                        removed  = icons.git.removed,
                    },
                },
            },

            lualine_x = {
                {
                    "diagnostics",
                    symbols = {
                        error = icons.diagnostics.Error,
                        warn  = icons.diagnostics.Warn,
                        hint  = icons.diagnostics.Hint,
                        info  = icons.diagnostics.Info,
                    },
                },
                lsp_name,
                "filetype",
            },

            lualine_y = { "progress" },

            lualine_z = { "location" },

        },

        inactive_sections = {
            lualine_c = { "filename" },
            lualine_x = { "location" },
        },

    }

end

return M
