--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/git/config/gitsigns.lua
--
-- Purpose:
--   Configuration for the Version Control Engine (gitsigns.nvim).
--
-- Responsibilities:
--   • Gutter sign appearance (added, changed, deleted indicators).
--   • Inline blame configuration.
--   • Hunk navigation and preview keymaps.
--
-- Notes:
--   Signs use icons from core.icons.git for consistency.
--   Keymaps are registered here (not in which-key.lua) because they
--   depend on gitsigns being loaded first.
--------------------------------------------------------------------------------

local M = {}

local icons = require("core.icons")

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

M.opts = {

    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
    },

    current_line_blame = false,

    current_line_blame_opts = {
        virt_text         = true,
        virt_text_pos     = "eol",
        delay             = 500,
        ignore_whitespace = false,
    },

    sign_priority = 6,

    update_debounce = 100,

    preview_config = {
        border   = "rounded",
        style    = "minimal",
        relative = "cursor",
        row      = 0,
        col      = 1,
    },

}

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

function M.setup_keymaps(gs)

    local km = require("core.keymaps")

    km.n("<leader>gh", gs.preview_hunk,       "Git: Preview Hunk")
    km.n("<leader>gb", gs.blame_line,          "Git: Blame Line")
    km.n("<leader>gB", gs.toggle_current_line_blame, "Git: Toggle Blame")
    km.n("<leader>gd", gs.diffthis,            "Git: Diff This")
    km.n("<leader>gD", function() gs.diffthis("~") end, "Git: Diff Previous")
    km.n("<leader>gR", gs.reset_buffer,        "Git: Reset Buffer")
    km.n("<leader>gr", gs.reset_hunk,          "Git: Reset Hunk")
    km.n("<leader>gs", gs.stage_hunk,          "Git: Stage Hunk")
    km.n("<leader>gS", gs.stage_buffer,        "Git: Stage Buffer")
    km.n("<leader>gu", gs.undo_stage_hunk,     "Git: Undo Stage Hunk")

    -- Hunk navigation
    km.n("]h", function()
        if vim.wo.diff then return "]h" end
        gs.next_hunk()
    end, "Git: Next Hunk")

    km.n("[h", function()
        if vim.wo.diff then return "[h" end
        gs.prev_hunk()
    end, "Git: Previous Hunk")

    -- Visual: stage selected lines
    km.v("<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Git: Stage Selected Lines")

    km.v("<leader>gr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Git: Reset Selected Lines")

end

return M
