-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme/registry.lua
--
-- Purpose:
--   Theme registry with file-system hierarchy loading.
--
-- Responsibilities:
--   • Maintain the built-in theme definitions.
--   • Load user-defined themes from JSON files on disk.
--   • Merge themes from multiple sources with priority ordering.
--   • Provide lookup APIs for the theme engine.
--
-- Notes:
--   Theme loading follows this priority (later overrides earlier):
--     1. Built-in themes (embedded in builtin.lua).
--     2. User config:  ~/.config/nvim/themes/*.json
--     3. Project root: .nvim/themes/*.json (relative to .git parent)
--     4. Current dir:  ./.nvim/themes/*.json
--
--   This mirrors opencode's theme loading hierarchy.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------

local builtin = require("core.theme.builtin")

-------------------------------------------------------------------------------
-- Registry state
-------------------------------------------------------------------------------

--- Built-in theme definitions. Populated at module load time from
--- builtin.lua. The "system" theme is injected by init() at startup.
--- @type table<string, table>
local M = {
    builtin = vim.deepcopy(builtin),
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

--- Build the list of file-system directories to search for JSON theme files.
--- Directories are returned in priority order (later = higher priority).
---
--- @return string[]
local function search_paths()
    local paths = {}

    local config_dir = vim.fn.stdpath("config") .. "/themes"
    if vim.fn.isdirectory(config_dir) == 1 then
        table.insert(paths, config_dir)
    end

    local cwd_dir = vim.fn.getcwd() .. "/.nvim/themes"
    if vim.fn.isdirectory(cwd_dir) == 1 then
        table.insert(paths, cwd_dir)
    end

    local git_dir = vim.fn.finddir(".git", ".;")
    if git_dir and git_dir ~= "" then
        local proj_dir = vim.fn.fnamemodify(git_dir, ":h") .. "/.nvim/themes"
        if vim.fn.isdirectory(proj_dir) == 1 then
            table.insert(paths, proj_dir)
        end
    end

    return paths
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Return every known theme, merging built-in and file-system sources.
--- File-system themes override built-in themes with the same name.
---
--- @return table<string, table>
function M.all()
    local themes = {}

    for name, theme in pairs(M.builtin) do
        themes[name] = vim.deepcopy(theme)
    end

    for _, dir in ipairs(search_paths()) do
        local ok, entries = pcall(vim.fn.readdir, dir)
        if ok then
            for _, file in ipairs(entries) do
                if file:match("%.json$") then
                    local name = file:gsub("%.json$", "")
                    local fh = io.open(dir .. "/" .. file, "r")
                    if fh then
                        local content = fh:read("*a")
                        fh:close()
                        local ok_json, data = pcall(vim.json.decode, content)
                        if ok_json and data and data.name then
                            themes[data.name] = {
                                name        = data.name,
                                label       = data.label or data.name,
                                colorscheme = data.colorscheme,
                                lualine     = data.lualine,
                                highlights  = data.highlights or {},
                                defs        = data.defs or {},
                                type        = data.type or "dark",
                                source      = "user",
                            }
                        end
                    end
                end
            end
        end
    end

    return themes
end

--- Return a single theme definition by name.
---
--- @param name string
--- @return table|nil
function M.get(name)
    local all = M.all()
    return all[name]
end

--- Return sorted list of all known theme names.
---
--- @return string[]
function M.names()
    local names = {}
    for name in pairs(M.all()) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return M
