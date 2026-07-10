--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/core/helpers.lua
--
-- Purpose:
--   PDE standard library for general-purpose utility functions.
--
-- Responsibilities:
--   • Table utilities
--   • String utilities
--   • System/environment utilities
--   • Plugin availability utilities
--
-- Notes:
--   Functions here must be side-effect free unless explicitly documented
--   otherwise. They should be usable from any layer of the PDE.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Table Utilities
--------------------------------------------------------------------------------

--- Deep-merge any number of tables, with later tables taking precedence.
---
--- @param ... table  Tables to merge.
--- @return table
function M.merge(...)
    return vim.tbl_deep_extend("force", ...)
end

--- Return true if the given table has no entries.
---
--- @param t table
--- @return boolean
function M.is_empty_table(t)
    return next(t) == nil
end

--------------------------------------------------------------------------------
-- String Utilities
--------------------------------------------------------------------------------

--- Return true if value is nil or an empty string.
---
--- @param value any
--- @return boolean
function M.is_empty(value)
    return value == nil or value == ""
end

--- Trim leading and trailing whitespace from a string.
---
--- @param s string
--- @return string
function M.trim(s)
    return s:match("^%s*(.-)%s*$")
end

--------------------------------------------------------------------------------
-- System / Environment Utilities
--------------------------------------------------------------------------------

--- Return true if the named executable is available on PATH.
---
--- Use this to conditionally enable features that depend on external tools.
--- For example: if core.helpers.executable("javac") then ... end
---
--- @param name string  Executable name (e.g. "javac", "mvn", "node").
--- @return boolean
function M.executable(name)
    return vim.fn.executable(name) == 1
end

--- Return true if the named file or directory exists on disk.
---
--- @param path string  Absolute path to check.
--- @return boolean
function M.path_exists(path)
    return vim.uv.fs_stat(path) ~= nil
end

--------------------------------------------------------------------------------
-- Plugin Utilities
--------------------------------------------------------------------------------

--- Return true if the named plugin is currently loaded.
---
--- Uses pcall to safely require without raising an error if the plugin
--- is not installed. Useful for optional feature guards.
---
--- @param name string  Plugin require path (e.g. "telescope").
--- @return boolean
function M.has_plugin(name)
    local ok = pcall(require, name)
    return ok
end

--- Safely call a function, logging an error if it fails.
---
--- @param fn   function  The function to call.
--- @param desc string    Human-readable description for error messages.
--- @return any           The return value of fn, or nil on failure.
function M.safe_call(fn, desc)
    local ok, result = pcall(fn)
    if not ok then
        require("core.logging").error(
            ("PDE: error in %s: %s"):format(desc, tostring(result)),
            "PDE Error"
        )
        return nil
    end
    return result
end

return M
