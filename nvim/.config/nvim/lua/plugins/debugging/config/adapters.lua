--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/debugging/config/adapters.lua
--
-- Purpose:
--   Debug adapter registrations for the Debug Engine.
--
-- Responsibilities:
--   • Register the codelldb adapter for C/C++ debugging.
--   • Register DAP configurations for C, C++, and Java.
--
-- Notes:
--   JAVA DEBUGGING:
--   Java debug configurations are intentionally minimal here. The main
--   Java debug setup is done inside plugins/languages/config/java.lua
--   via jdtls.setup_dap(). The configuration below provides a remote
--   attach option for connecting to a running JVM process.
--
--   CODELLDB:
--   codelldb is a native LLDB-based debug adapter for C, C++, and Rust.
--   It is installed by mason-nvim-dap (ensure_installed = { "codelldb" }).
--   The binary is resolved from Mason's install path via core.paths.
--
--   PORT BINDING:
--   codelldb uses a dynamic port (${port}) — DAP picks a free port
--   and passes it to the adapter executable at launch time.
--------------------------------------------------------------------------------

local M = {}

local paths = require("core.paths")

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Register all debug adapters and configurations with nvim-dap.
--- Called once from the DAP plugin config function.
function M.setup()

    local dap = require("dap")

    --------------------------------------------------------------------------
    -- codelldb Adapter (C / C++ / Rust)
    --------------------------------------------------------------------------

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = paths.data .. "/mason/bin/codelldb",
            args    = { "--port", "${port}" },
        },
    }

    --------------------------------------------------------------------------
    -- C Configuration
    --------------------------------------------------------------------------

    dap.configurations.c = {
        {
            name    = "Launch (codelldb)",
            type    = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input(
                    "Path to executable: ",
                    vim.fn.getcwd() .. "/",
                    "file"
                )
            end,
            cwd          = "${workspaceFolder}",
            stopOnEntry  = false,
        },
    }

    --------------------------------------------------------------------------
    -- C++ Configuration (inherits C)
    --------------------------------------------------------------------------

    dap.configurations.cpp = dap.configurations.c

    --------------------------------------------------------------------------
    -- Rust Configuration (reuses codelldb adapter)
    --------------------------------------------------------------------------
    --
    -- Rust uses the same codelldb adapter as C/C++. No separate adapter
    -- registration is needed.
    --------------------------------------------------------------------------

    dap.configurations.rust = {
        {
            name    = "Launch (codelldb)",
            type    = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input(
                    "Path to executable: ",
                    vim.fn.getcwd() .. "/target/debug/",
                    "file"
                )
            end,
            cwd          = "${workspaceFolder}",
            stopOnEntry  = false,
        },
    }

    --------------------------------------------------------------------------
    -- Java Configuration (remote attach)
    --------------------------------------------------------------------------
    --
    -- Full Java DAP setup is handled by jdtls.setup_dap() inside
    -- plugins/languages/config/java.lua. This entry provides a
    -- remote-attach option for connecting to an external JVM.
    --------------------------------------------------------------------------

    dap.configurations.java = {
        {
            type      = "java",
            request   = "attach",
            name      = "Debug (Attach Remote JVM)",
            hostName  = "127.0.0.1",
            port      = 5005,
        },
    }

end

return M
