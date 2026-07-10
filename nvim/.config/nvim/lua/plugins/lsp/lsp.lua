--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/lsp/lsp.lua
--
-- Purpose:
--   Plugin specification for the Language Intelligence Engine.
--
-- Subsystem:  LSP
-- Adapters:   mason.nvim, mason-lspconfig.nvim, nvim-lspconfig
--
-- Responsibilities:
--   • Declare Mason + mason-lspconfig + lspconfig dependency chain.
--   • Wire together: Mason (installer) → mason-lspconfig (bridge) →
--     lspconfig (server config) → cmp-nvim-lsp (capabilities).
--   • Delegate server list to config/servers.lua.
--   • Delegate keymaps to config/keymaps.lua.
--   • Delegate diagnostic UI to config/diagnostics.lua.
--
-- Notes:
--   INITIALIZATION ORDER (critical):
--     1. mason.setup()             — must run first
--     2. Build LSP capabilities    — from cmp_nvim_lsp
--     3. mason-lspconfig.setup()  — installs servers, runs handlers
--     4. LspAttach autocmd         — registers keymaps per buffer
--     5. diagnostics.setup()      — configures diagnostic UI
--
--   The capabilities object is built from cmp_nvim_lsp.default_capabilities()
--   and passed to every server handler. This tells each LSP server that
--   the client supports snippet completions and other cmp-specific features.
--------------------------------------------------------------------------------

return {

    "neovim/nvim-lspconfig",

    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },

    config = function()

        local servers     = require("plugins.lsp.config.servers")
        local lsp_keymaps = require("plugins.lsp.config.keymaps")
        local diagnostics = require("plugins.lsp.config.diagnostics")

        --------------------------------------------------------------------
        -- 1. Mason
        --------------------------------------------------------------------

        require("mason").setup({
            ui = {
                border = require("core.constants").UI.BORDER,
                icons  = {
                    package_installed   = "✓",
                    package_pending     = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        --------------------------------------------------------------------
        -- 2. Build LSP Capabilities
        --------------------------------------------------------------------
        --
        -- Merges default Neovim LSP capabilities with nvim-cmp's extended
        -- capabilities (snippet support, additional completion kinds, etc.)
        --------------------------------------------------------------------

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        --------------------------------------------------------------------
        -- 3. Mason-lspconfig
        --------------------------------------------------------------------
        --
        -- Ensures listed servers are installed and routes each through
        -- a handler. Servers without a custom handler use the default.
        --------------------------------------------------------------------

        -- Build the handlers table:
        --   [1]        = default handler (required by mason-lspconfig)
        --   [servername] = per-server override (from config/servers.lua)
        local handlers = {
            -- Default: called for every server without a custom entry
            function(server_name)
                require("lspconfig")[server_name].setup({
                    capabilities = capabilities,
                })
            end,
        }

        -- Inject the shared capabilities object into each custom handler
        for name, handler in pairs(servers.handlers) do
            handlers[name] = function()
                handler(capabilities)
            end
        end

        require("mason-lspconfig").setup({
            ensure_installed       = servers.ensure_installed,
            automatic_installation = true,
            handlers               = handlers,
        })

        --------------------------------------------------------------------
        -- 4. LspAttach — Register Keymaps
        --------------------------------------------------------------------

        vim.api.nvim_create_autocmd("LspAttach", {

            group = vim.api.nvim_create_augroup("PDELspAttach", { clear = true }),

            desc = "Register buffer-local LSP keymaps on attach",

            callback = function(event)
                lsp_keymaps.on_attach(event.buf)
            end,

        })

        --------------------------------------------------------------------
        -- 5. Diagnostic UI
        --------------------------------------------------------------------

        diagnostics.setup()

    end,

}
