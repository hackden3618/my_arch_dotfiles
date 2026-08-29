--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/snacks.lua
--
-- Purpose:
--   Plugin specification for the Snacks.nvim multi-tool (guides only).
--
-- Subsystem:  UI › Indent Guides + Animated Scope
-- Adapter:    folke/snacks.nvim
--
-- Responsibilities:
--   • Provide animated indentation guides + current-scope highlight.
--   • Provide git integration used elsewhere (explorer gutter, etc.).
--
-- Notes:
--   The Snacks file EXPLORER is intentionally disabled here — the user
--   kept their own nvim-tree.lua explorer (which already shows git states),
--   so only the indentation guides / scope remain enabled.
--------------------------------------------------------------------------------

return {

    "folke/snacks.nvim",

    priority = 1000,

    lazy = false,

    opts = {

        ------------------------------------------------------------------------
        -- File explorer is provided by nvim-tree (kept per user preference)
        ------------------------------------------------------------------------

        explorer = { enabled = false },

        ------------------------------------------------------------------------
        -- Static indentation guide lines
        ------------------------------------------------------------------------

        indent = {
            enabled = true,
        },

        ------------------------------------------------------------------------
        -- Animated current indentation scope (the highlighted block)
        ------------------------------------------------------------------------

        scope = {
            enabled = true,
        },

        ------------------------------------------------------------------------
        -- Git integration (gutter / explorer support)
        ------------------------------------------------------------------------

        git = {
            enabled = true,
        },

        ------------------------------------------------------------------------
        -- Disable Snacks modules that would clash with existing plugins
        ------------------------------------------------------------------------

        -- nvim-notify already owns global notifications.
        notifier = { enabled = false },

        -- statuscolumn / scroll are handled by the core options + other plugins.
        statuscolumn = { enabled = false },
        scroll = { enabled = false },
    },
}
