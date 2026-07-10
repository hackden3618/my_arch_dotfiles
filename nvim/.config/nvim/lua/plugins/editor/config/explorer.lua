--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/explorer.lua
--
-- Purpose:
--   Configuration for the Explorer Engine (nvim-tree.lua).
--
-- Responsibilities:
--   • nvim-tree visual and behavioral options.
--   • File explorer keymap (<C-n> toggle).
--   • Disable netrw in favor of nvim-tree.
--
-- Notes:
--   netrw is disabled via vim.g flags set BEFORE nvim-tree loads.
--   This is a documented requirement of nvim-tree — netrw must be
--   disabled at startup, not after.
--
--   The <C-n> keymap is registered here (not in the plugin spec's keys
--   table) because we need access to the nvim-tree API to bind to the
--   toggle_tree_toggle function.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()

    local nvim_tree = require("nvim-tree")
    local api       = require("nvim-tree.api")
    local km        = require("core.keymaps")

    --------------------------------------------------------------------------
    -- Plugin Configuration
    --------------------------------------------------------------------------

    nvim_tree.setup({

        sort = {
            sorter = "case_sensitive",
        },

        view = {
            width = 35,
            side  = "left",
        },

        renderer = {
            group_empty    = true,
            highlight_git  = true,
            icons = {
                show = {
                    git     = true,
                    file    = true,
                    folder  = true,
                },
            },
        },

        filters = {
            dotfiles = false,
            custom   = { "^.git$" },
        },

        git = {
            enable  = true,
            ignore  = false,
        },

        actions = {
            open_file = {
                quit_on_open = false,
                window_picker = {
                    enable = true,
                },
            },
        },

    })

    --------------------------------------------------------------------------
    -- Keymaps
    --------------------------------------------------------------------------

    km.n("<C-n>", api.tree.toggle, "Toggle File Explorer")

end

return M
