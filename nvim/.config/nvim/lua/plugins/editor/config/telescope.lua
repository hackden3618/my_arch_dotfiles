--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/telescope.lua
--
-- Purpose:
--   Configuration for the Search Engine (telescope.nvim).
--
-- Responsibilities:
--   • Telescope defaults (layout, path display, navigation mappings).
--   • Extension registration (fzf-native, ui-select).
--   • Search keymaps (<leader>f namespace).
--
-- Notes:
--   EXTENSION LOADING ORDER:
--     1. require("telescope").setup({ extensions = { ... } })
--     2. telescope.load_extension("fzf")
--     3. telescope.load_extension("ui-select")
--
--   Extensions MUST be loaded after setup(). Calling load_extension()
--   before or inside setup() is a common misconfiguration that causes
--   silent failures.
--
--   ui-select replaces vim.ui.select() globally, which means LSP code
--   actions, rename prompts, and any plugin using vim.ui.select() will
--   automatically use Telescope's dropdown interface.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Keys
--------------------------------------------------------------------------------
--
-- Returned to the plugin spec for lazy-loading trigger registration.
-- These same keys are also mapped in setup() via core.keymaps.
--------------------------------------------------------------------------------

M.keys = {
    { "<leader>ff", desc = "Find Files" },
    { "<leader>fg", desc = "Live Grep" },
    { "<leader>fb", desc = "Find Buffers" },
    { "<leader>fh", desc = "Find Help Tags" },
    { "<leader>fr", desc = "Recent Files" },
    { "<leader>fc", desc = "Find Config Files" },
    { "<leader>fd", desc = "Find Diagnostics" },
}

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()

    local telescope = require("telescope")
    local actions   = require("telescope.actions")
    local themes    = require("telescope.themes")
    local builtin   = require("telescope.builtin")
    local km        = require("core.keymaps")

    --------------------------------------------------------------------------
    -- Core Configuration
    --------------------------------------------------------------------------

    telescope.setup({

        defaults = {

            path_display = { "truncate" },

            sorting_strategy = "ascending",

            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width   = 0.55,
                },
            },

            mappings = {
                i = {
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    ["<Esc>"] = actions.close,
                },
            },

        },

        extensions = {

            fzf = {
                fuzzy                   = true,
                override_generic_sorter = true,
                override_file_sorter    = true,
                case_mode               = "smart_case",
            },

            ["ui-select"] = {
                themes.get_dropdown({
                    winblend  = 10,
                    previewer = false,
                }),
            },

        },

    })

    --------------------------------------------------------------------------
    -- Load Extensions
    --------------------------------------------------------------------------
    --
    -- Extensions must be loaded AFTER setup() — never before or inside it.
    --------------------------------------------------------------------------

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    --------------------------------------------------------------------------
    -- Keymaps
    --------------------------------------------------------------------------

    km.n("<leader>ff", builtin.find_files,                "Find Files")
    km.n("<leader>fg", builtin.live_grep,                 "Live Grep")
    km.n("<leader>fb", builtin.buffers,                   "Find Buffers")
    km.n("<leader>fh", builtin.help_tags,                 "Find Help Tags")
    km.n("<leader>fr", builtin.oldfiles,                  "Recent Files")
    km.n("<leader>fd", builtin.diagnostics,               "Find Diagnostics")
    km.n("<leader>fc", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, "Find Config Files")

end

return M
