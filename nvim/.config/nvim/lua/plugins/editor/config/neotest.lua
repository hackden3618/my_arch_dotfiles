--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/neotest.lua
--
-- Purpose:
--   Configuration for the Test Engine (neotest).
--
-- Responsibilities:
--   • Register language adapters (jest, python).
--   • Configure neotest output and summary behavior.
--   • Register test keymaps in the <leader>T namespace.
--
-- Notes:
--   JEST CONFIGURATION:
--   jestCommand is left at default ("jest") which picks up the local
--   node_modules/.bin/jest. For Vitest projects, set jestCommand to
--   "vitest run" per project using a .neotest.lua file.
--
--   PYTHON CONFIGURATION:
--   Uses pytest as the default runner. The runner is auto-detected
--   from the project's pyproject.toml or setup.cfg.
--------------------------------------------------------------------------------

local M = {}

M.keys = {
    { "<leader>Tn", function() require("neotest").run.run() end,
        desc = "Test: Run Nearest" },
    { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,
        desc = "Test: Run File" },
    { "<leader>Ts", function() require("neotest").summary.toggle() end,
        desc = "Test: Summary Panel" },
    { "<leader>To", function() require("neotest").output_panel.toggle() end,
        desc = "Test: Output Panel" },
    { "<leader>Tq", function() require("neotest").run.stop() end,
        desc = "Test: Stop Run" },
    { "<leader>Ta", function() require("neotest").run.run(vim.fn.getcwd()) end,
        desc = "Test: Run All (Workspace)" },
}

function M.setup()

    require("neotest").setup({

        adapters = {

            require("neotest-jest")({
                jestCommand      = "npx jest",
                jestConfigFile   = "jest.config.js",
                env              = { CI = true },
                cwd              = function() return vim.fn.getcwd() end,
            }),

            require("neotest-python")({
                dap          = { justMyCode = false },
                runner       = "pytest",
                python       = ".venv/bin/python",
            }),

        },

        output = {
            open_on_run = "short",
        },

        summary = {
            animated = true,
        },

        icons = {
            failed        = " ",
            passed        = " ",
            running       = " ",
            skipped       = " ",
            unknown       = " ",
        },

    })

end

return M
