--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/which-key.lua
--
-- Purpose:
--   Configuration for the Command Engine (which-key.nvim).
--
-- Responsibilities:
--   • Plugin appearance settings (border, layout)
--   • Global key group label registration
--
-- Notes:
--   This file centralizes ALL which-key group labels for the PDE.
--   Individual subsystems may also call core.keymaps.group() to register
--   their own groups at load time, but the primary groups (leader prefixes)
--   are declared here for clarity and discoverability.
--
--   The `spec` table is which-key v3 format. Each entry is:
--     { "<prefix>", group = "<label>" }
--------------------------------------------------------------------------------

return {

    --------------------------------------------------------------------------------
    -- Appearance
    --------------------------------------------------------------------------------

    preset = "modern",

    win = {
        border = "rounded",
    },

    layout = {
        spacing = 3,
    },

    --------------------------------------------------------------------------------
    -- Plugin Settings
    --------------------------------------------------------------------------------

    plugins = {
        marks     = true,
        registers = true,
        spelling  = {
            enabled     = true,
            suggestions = 20,
        },
    },

    --------------------------------------------------------------------------------
    -- Key Group Labels
    --------------------------------------------------------------------------------
    --
    -- These are the top-level <leader> group definitions visible to every
    -- subsystem. Plugin-specific sub-groups are registered within their
    -- own config modules.
    --------------------------------------------------------------------------------

    spec = {

        -- Navigation
        { "<leader>p",  group = "Project" },
        { "<leader>f",  group = "Find" },
        { "<leader>b",  group = "Buffers" },
        { "<leader>bs", group = "Sort Buffers" },

        -- Code Intelligence
        { "<leader>c",  group = "Code" },

        -- Source Control
        { "<leader>g",  group = "Git" },

        -- Debug & Run
        { "<leader>d",  group = "Debug" },
        { "<leader>r",  group = "Run" },

        -- Diagnostics / Trouble
        { "<leader>x", group = "Diagnostics" },

        -- Testing
        { "<leader>T", group = "Testing" },

        -- Language-Specific
        { "<leader>j",  group = "Java" },
        { "<leader>m",  group = "Maven" },

        -- Editor Chrome
        { "<leader>w",  group = "Windows" },
        { "<leader>t",  group = "Terminal" },
        { "<leader>l",  group = "Live" },
        { "<leader>u",  group = "UI" },

    },

}
