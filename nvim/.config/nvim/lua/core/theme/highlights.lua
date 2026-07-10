-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme/highlights.lua
--
-- Purpose:
--   Apply Neovim highlight groups from theme definition tables.
--
-- Responsibilities:
--   • Resolve color values (hex, named references from defs, none).
--   • Parse style strings (bold, italic, underline, undercurl, etc.).
--   • Call nvim_set_hl for each highlight group in a theme definition.
--
-- Notes:
--   Color resolution supports:
--     "#RRGGBB"   — Direct hex color.
--     "name"      — Reference to a key in the defs table.
--     "none"/nil  — Terminal default (key is omitted from nvim_set_hl).
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

--- Set of valid Neovim highlight style flags.
local STYLE_FLAGS = {
    bold         = true,
    italic       = true,
    underline    = true,
    undercurl    = true,
    strikethrough = true,
    reverse      = true,
    standout     = true,
    nocombine    = true,
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

--- Resolve a color value to a hex string or nil.
---
--- @param value any     The color value from a theme definition.
--- @param defs table    Color definitions for named references.
--- @return string|nil
local function resolve_color(value, defs)
    if value == nil or value == "none" then
        return nil
    end
    if type(value) == "number" then
        return nil
    end
    if type(value) == "string" then
        if value:match("^#") then
            return value
        end
        if defs and defs[value] then
            return resolve_color(defs[value], defs)
        end
        return nil
    end
    return nil
end

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local M = {}

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Apply a set of highlight group definitions.
--- Each key in `highlights` is a Neovim highlight group name.
--- Each value is a table with optional keys: fg, bg, sp, style, link.
---
--- @param highlights table<string, table>
--- @param defs       table  Color definitions for named references.
function M.apply(highlights, defs)
    for group, opts in pairs(highlights) do
        local hl = {}

        if opts.fg then
            local c = resolve_color(opts.fg, defs)
            if c then hl.fg = c end
        end

        if opts.bg then
            local c = resolve_color(opts.bg, defs)
            if c then hl.bg = c end
        end

        if opts.sp then
            local c = resolve_color(opts.sp, defs)
            if c then hl.sp = c end
        end

        if opts.style then
            for s in opts.style:gmatch("[%w_]+") do
                local s_lower = s:lower()
                if STYLE_FLAGS[s_lower] then
                    hl[s_lower] = true
                end
            end
        end

        if opts.link then
            hl.link = opts.link
            hl.default = true
        end

        if next(hl) then
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end

return M
