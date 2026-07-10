--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/keymaps.lua
--
-- Purpose:
--   PDE standard library for keymap registration.
--
-- Responsibilities:
--   • Provide typed wrappers around vim.keymap.set for all modes.
--   • Enforce noremap + silent defaults on every binding.
--   • Provide a group() helper for which-key label registration.
--
-- Notes:
--   All plugin keymaps should use this module instead of calling
--   vim.keymap.set directly. This ensures a single point of change
--   if defaults or behavior ever need to evolve.
--
--   Mode reference:
--     n  = Normal
--     i  = Insert
--     v  = Visual (character)
--     x  = Visual (block, excludes select)
--     t  = Terminal
--    nv  = Normal + Visual (convenience combination)
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local map = vim.keymap.set

--------------------------------------------------------------------------------
-- Internals
--------------------------------------------------------------------------------

--- Build a standardized options table for a keymap.
---
--- @param desc string Human-readable description shown in which-key.
--- @param extra table|nil Additional options to merge (e.g. { buffer = 0 }).
--- @return table
local function build_opts(desc, extra)
    local defaults = {
        noremap = true,
        silent  = true,
        desc    = desc,
    }
    if extra then
        return vim.tbl_extend("force", defaults, extra)
    end
    return defaults
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Register a Normal-mode keymap.
---
--- @param lhs    string  Left-hand side (key sequence).
--- @param rhs    string|function  Right-hand side (command or callback).
--- @param desc   string  Human-readable description.
--- @param opts   table|nil  Additional options.
function M.n(lhs, rhs, desc, opts)
    map("n", lhs, rhs, build_opts(desc, opts))
end

--- Register an Insert-mode keymap.
---
--- @param lhs    string
--- @param rhs    string|function
--- @param desc   string
--- @param opts   table|nil
function M.i(lhs, rhs, desc, opts)
    map("i", lhs, rhs, build_opts(desc, opts))
end

--- Register a Visual-mode keymap (character + line visual).
---
--- @param lhs    string
--- @param rhs    string|function
--- @param desc   string
--- @param opts   table|nil
function M.v(lhs, rhs, desc, opts)
    map("v", lhs, rhs, build_opts(desc, opts))
end

--- Register an eXclusive-visual mode keymap (excludes Select mode).
---
--- @param lhs    string
--- @param rhs    string|function
--- @param desc   string
--- @param opts   table|nil
function M.x(lhs, rhs, desc, opts)
    map("x", lhs, rhs, build_opts(desc, opts))
end

--- Register a Terminal-mode keymap.
---
--- @param lhs    string
--- @param rhs    string|function
--- @param desc   string
--- @param opts   table|nil
function M.t(lhs, rhs, desc, opts)
    map("t", lhs, rhs, build_opts(desc, opts))
end

--- Register a keymap for both Normal and Visual modes.
---
--- @param lhs    string
--- @param rhs    string|function
--- @param desc   string
--- @param opts   table|nil
function M.nv(lhs, rhs, desc, opts)
    map({ "n", "v" }, lhs, rhs, build_opts(desc, opts))
end

--- Register a which-key group label for a key prefix.
---
--- Provides a descriptive label for key groups without creating
--- a functional keymap. Requires which-key.nvim to be loaded.
---
--- @param prefix string  Key prefix (e.g. "<leader>c").
--- @param label  string  Human-readable group name (e.g. "Code").
--- @param mode   string|nil  Mode (default: "n").
function M.group(prefix, label, mode)
    -- Defer to allow which-key to be loaded first.
    vim.schedule(function()
        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.add({ { prefix, group = label, mode = mode or "n" } })
        end
    end)
end

return M
