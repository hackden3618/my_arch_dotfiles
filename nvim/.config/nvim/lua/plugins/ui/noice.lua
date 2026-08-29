--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/noice.lua
--
-- Purpose:
--   Plugin specification for the Message / notification UI (noice.nvim).
--
-- Subsystem:  UI › Message Engine
-- Adapter:    folke/noice.nvim
--
-- Responsibilities:
--   • Route Neovim messages, errors and notifications through a clean UI.
--   • Deliver long messages to a split instead of blocking the cmdline.
--
-- Notes:
--   The COMMAND-LINE UI is intentionally disabled here — wilder.nvim owns
--   the : / ? command line (live fuzzy suggestions). noice only handles
--   messages/notifications so the two do not fight over the cmdline.
--------------------------------------------------------------------------------

return {

    "folke/noice.nvim",

    event = "VeryLazy",

    priority = 900,

    dependencies = {
        "MunifTanjim/nui.nvim",
    },

    opts = {

        presets = {
            bottom_search = false,
            command_palette = false,
            long_message_to_split = true,
        },

        views = {
            -- wilder.nvim owns the command-line; disable noice's cmdline UI.
            cmdline = { enabled = false },
            cmdline_popup = { enabled = false },
            cmdline_popupmenu = { enabled = false },
        },
    },
}
