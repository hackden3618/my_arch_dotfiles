-------------------------------------------------------------------------------
-- Neovim PDE
-------------------------------------------------------------------------------
-- File: lua/core/theme/init.lua
--
-- Purpose:
--   Theme Engine — switch, persist, and discover themes.
--
-- Responsibilities:
--   • Set the active colorscheme and apply highlight overrides.
--   • Reload lualine after theme switches.
--   • Persist the active theme choice across sessions.
--   • Register :ThemeSet, :ThemeNext, and :Theme user commands.
--
-- Notes:
--   This is the central API consumed by config/init.lua and
--   plugins/ui/config/lualine.lua.
--
--   Theme switching sequence:
--     1. Run :colorscheme (if the theme specifies one — lazy.nvim
--        intercepts this to load the plugin).
--     2. Fall back to "default" if no colorscheme (clears previous).
--     3. Apply custom highlight overrides from the theme definition.
--     4. Reload lualine with the new theme.
--     5. Persist the choice.
--
--   The "system" theme has no colorscheme and resets everything to
--   terminal defaults.
--
--   opencode INFLUENCE:
--     This system is inspired by opencode's JSON-based theme engine:
--     • /theme interactive picker (via vim.ui.select)
--     • JSON theme files in ~/.config/nvim/themes/
--     • Colour definitions (defs) with named references
--     • Hierarchy: built-in → user config → project → cwd
--     • "system" theme that adapts to terminal colors
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------

local logging   = require("core.logging")
local registry  = require("core.theme.registry")
local highlight = require("core.theme.highlights")
local system    = require("core.theme.system")

-------------------------------------------------------------------------------
-- State
-------------------------------------------------------------------------------

--- The currently active theme name. Always one of M.available().
local current_theme = "catppuccin"

--- Whether the persisted theme has been restored this session.
local persisted = false

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function persist_path()
    return vim.fn.stdpath("config") .. "/lua/.theme"
end

local function persist(name)
    local path = persist_path()
    local file = io.open(path, "w")
    if file then
        file:write(name)
        file:close()
    end
end

local function load_persisted()
    local path = persist_path()
    local file = io.open(path, "r")
    if file then
        local name = file:read("*l")
        file:close()
        return name
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

--- Return the sorted list of all known theme names.
---
--- @return string[]
function M.available()
    return registry.names()
end

--- Return the configuration table of the currently active theme.
---
--- @return table
function M.current()
    local all = registry.all()
    local theme = all[current_theme]
    if theme then
        return theme
    end
    local fallback = all["catppuccin"]
    return fallback or {
        name    = "catppuccin",
        label   = "Catppuccin Mocha",
        lualine = "catppuccin-mocha",
    }
end

--- Return the lualine theme name for the currently active theme.
--- Called by plugins/ui/config/lualine.lua at startup and on switch.
---
--- @return string
function M.lualine_theme()
    return M.current().lualine or "auto"
end

--- Switch to a named theme.
---
--- @param name string  A theme name from M.available().
--- @return boolean     true if the switch succeeded.
function M.set(name)
    local all = registry.all()
    local theme = all[name]
    if not theme then
        logging.error("Unknown theme: " .. name, "Theme")
        return false
    end

    if name == current_theme and persisted then
        return true
    end

    current_theme = name

    --------------------------------------------------------------------------
    -- 1. Apply colorscheme or reset to defaults
    --------------------------------------------------------------------------

    if theme.colorscheme then
        pcall(vim.cmd.colorscheme, theme.colorscheme)
    else
        pcall(vim.cmd.colorscheme, "default")
    end

    --------------------------------------------------------------------------
    -- 2. Apply custom highlight overrides
    --------------------------------------------------------------------------

    if theme.highlights and next(theme.highlights) then
        highlight.apply(theme.highlights, theme.defs)
    end

    --------------------------------------------------------------------------
    -- 3. Reload lualine
    --------------------------------------------------------------------------

    local ok_lualine, lualine = pcall(require, "lualine")
    if ok_lualine then
        local ok_cfg, cfg = pcall(require, "plugins.ui.config.lualine")
        if ok_cfg and cfg.get_config then
            lualine.setup(cfg.get_config())
        end
    end

    --------------------------------------------------------------------------
    -- 4. Persist
    --------------------------------------------------------------------------

    persist(name)
    persisted = true
    logging.info("Theme: " .. (theme.label or name), "Theme")
    return true
end

--- Initialize the theme system at startup.
--- Injects the system theme into the registry and restores the
--- persisted theme choice (if any).
function M.init()
    registry.builtin["system"] = system.generate()

    local persisted_name = load_persisted()
    if persisted_name and persisted_name ~= "catppuccin" then
        vim.schedule(function()
            M.set(persisted_name)
        end)
    end
end

--- Register :ThemeSet, :ThemeNext, and :Theme user commands.
function M.setup_commands()
    local api = vim.api

    api.nvim_create_user_command("ThemeSet", function(ctx)
        if ctx.args == "" then
            local avail = M.available()
            logging.info("Available: " .. table.concat(avail, ", "), "Theme")
            return
        end
        M.set(ctx.args)
    end, {
        nargs    = "?",
        complete = function() return M.available() end,
        desc     = "Switch to a theme (Tab-completes)",
    })

    api.nvim_create_user_command("ThemeNext", function()
        local avail = M.available()
        local idx = nil
        for i, name in ipairs(avail) do
            if name == current_theme then
                idx = i
                break
            end
        end
        M.set(avail[((idx or 1) % #avail) + 1])
    end, {
        desc = "Cycle to the next theme",
    })

    api.nvim_create_user_command("Theme", function()
        local items = {}
        local all = registry.all()
        for _, name in ipairs(M.available()) do
            local theme = all[name]
            table.insert(items, {
                name  = name,
                label = (theme and theme.label) or name,
            })
        end

        vim.ui.select(items, {
            prompt      = "Select a theme",
            format_item = function(item) return item.label end,
        }, function(choice)
            if choice then
                M.set(choice.name)
            end
        end)
    end, {
        desc = "Open interactive theme picker",
    })
end

return M
