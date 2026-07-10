--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/web.lua
--
-- Purpose:
--   Web development tooling configuration.
--
-- Responsibilities:
--   • Configure toggleterm for terminal management.
--   • Live server toggle keymap (<leader>ls).
--   • Quick runner keymaps for C and Python (<leader>rc, <leader>rp).
--
-- Notes:
--   LIVE SERVER:
--   The live-server NPM package must be installed globally:
--     npm install -g live-server
--   The server starts in the current file's directory, not the CWD.
--   This ensures it serves the correct project root when editing
--   HTML files nested inside a project.
--
--   TOGGLETERM:
--   Configured with <C-\> as the global terminal toggle.
--   Direction "horizontal" keeps it at the bottom like most IDEs.
--   close_on_exit = true automatically removes the split when done.
--
--   QUICK RUNNERS (<leader>r*):
--   These are global language runners, not Java-specific.
--   Java runners are managed in java-runners.lua.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local km = require("core.keymaps")

    --------------------------------------------------------------------------
    -- Toggleterm Configuration
    --------------------------------------------------------------------------

    require("toggleterm").setup({
        size          = 20,
        open_mapping  = [[<c-\>]],
        direction     = "horizontal",
        close_on_exit = true,
        shade_terminals = true,
        shading_factor  = 2,
    })

    --------------------------------------------------------------------------
    -- Live Server
    --------------------------------------------------------------------------

    local function toggle_live_server()
        local file_dir = vim.fn.expand("%:p:h")
        local cmd      = "live-server " .. vim.fn.shellescape(file_dir)
        vim.cmd("split")
        vim.cmd("term " .. cmd)
    end

    km.n("<leader>ls", toggle_live_server, "Live: Toggle Live Server")

    --------------------------------------------------------------------------
    -- Quick Language Runners
    --------------------------------------------------------------------------

    km.n("<leader>rc", ":split | term gcc % -o %:r && ./%:r<CR>",
        "Run: C (compile + execute)")

    km.n("<leader>rp", ":split | term python %<CR>",
        "Run: Python")

end

return M
