--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/lualine.lua
--
-- Purpose:
--   Configuration for the Status Engine (lualine.nvim).
--
-- Responsibilities:
--   • Recreate LazyVim's statusline look: mode, branch, project root,
--     diagnostics, filetype icon, file path, then on the right: noice
--     command/mode status, dap status, lazy updates, and a gitsigns
--     diff readout (added / modified / removed), progress, location, clock.
--   • theme = "auto" so the statusline tracks the active colorscheme
--     (e.g. tokyonight) and updates on :ThemeSet.
--
-- Notes:
--   This mirrors the LazyVim lualine layout but drops the LazyVim.*
--   helpers (root_dir / pretty_path) in favour of stock lualine
--   components and a small local root_dir() helper.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Show the current project root (basename) in the statusline.
local function root_dir()
    local root = vim.fs.root(0, { ".git", ".hg", ".svn", "lua", "package.json" })
        or vim.fn.getcwd()
    return " " .. vim.fn.fnamemodify(root, ":~:t")
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Build and return the complete lualine configuration table.
--- Called at startup (by the plugin spec) and on theme switch (core.theme.set).
---
--- @return table
function M.get_config()

    return {

        options = {
            theme = "auto",
            globalstatus = true,
            disabled_filetypes = {
                statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
            },
        },

        sections = {

            lualine_a = { "mode" },

            lualine_b = {
                { "branch", icon = "" },
            },

            lualine_c = {
                root_dir,
                {
                    "diagnostics",
                    symbols = {
                        error = "󰅚 ",
                        warn = "󰀪 ",
                        info = "󰋽 ",
                        hint = "󰌶 ",
                    },
                },
                { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                { "filename", path = 1, symbols = { modified = " [+]", readonly = " [-]" } },
            },

            lualine_x = {
                {
                    function()
                        return require("noice").api.status.command.get()
                    end,
                    cond = function()
                        return package.loaded["noice"] and require("noice").api.status.command.has()
                    end,
                    color = function()
                        return { fg = "#ff9e64" }
                    end,
                },
                {
                    function()
                        return require("noice").api.status.mode.get()
                    end,
                    cond = function()
                        return package.loaded["noice"] and require("noice").api.status.mode.has()
                    end,
                    color = function()
                        return { fg = "#7daea3" }
                    end,
                },
                {
                    function()
                        return "  " .. require("dap").status()
                    end,
                    cond = function()
                        return package.loaded["dap"] and require("dap").status() ~= ""
                    end,
                },
                {
                    require("lazy.status").updates,
                    cond = require("lazy.status").has_updates,
                    color = function()
                        return { fg = "#abcf91" }
                    end,
                },
                {
                    "diff",
                    symbols = {
                        added = " ",
                        modified = " ",
                        removed = " ",
                    },
                    source = function()
                        local g = vim.b.gitsigns_status_dict
                        if g then
                            return {
                                added = g.added,
                                modified = g.changed,
                                removed = g.removed,
                            }
                        end
                    end,
                },
            },

            lualine_y = {
                { "progress", separator = " ", padding = { left = 1, right = 0 } },
                { "location", padding = { left = 0, right = 1 } },
            },

            lualine_z = {
                function()
                    return " " .. os.date("%R")
                end,
            },
        },

        inactive_sections = {
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "location" },
        },

        extensions = { "nvim-tree", "lazy" },
    }
end

return M
