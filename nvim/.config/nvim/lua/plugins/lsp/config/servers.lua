--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/lsp/config/servers.lua
--
-- Purpose:
--   LSP server registry for the Language Intelligence Engine.
--
-- Responsibilities:
--   • List all servers that Mason should auto-install.
--   • Provide per-server configuration overrides.
--
-- Notes:
--   Server names must match mason-lspconfig's naming convention, which
--   is defined in core.constants.LSP for single-source-of-truth.
--
--   JDTLS (Java) is intentionally EXCLUDED from this list.
--   Reason: jdtls requires special lifecycle management that cannot
--   be handled by the standard mason-lspconfig handler. It is managed
--   exclusively by nvim-jdtls inside plugins/languages/java.lua.
--
--   DEFAULT HANDLER:
--   Any server listed in ensure_installed that does NOT have a custom
--   handler will use the default handler, which calls:
--     require("lspconfig")[server].setup({ capabilities = capabilities })
--
--   CUSTOM HANDLERS:
--   Servers requiring special settings are configured in M.handlers.
--------------------------------------------------------------------------------

local M = {}

local C = require("core.constants")

--------------------------------------------------------------------------------
-- Auto-install List
--------------------------------------------------------------------------------

M.ensure_installed = {}

-- M.ensure_installed = {
--
--     -- General / Editor
--     C.LSP.LUA,
--
--     -- Systems
--     C.LSP.CLANGD,
--
--     -- Web — Core
--     C.LSP.TYPESCRIPT,
--     C.LSP.HTML,
--     C.LSP.CSS,
--     C.LSP.TAILWIND,
--     C.LSP.EMMET,
--
--     -- Data / Config
--     C.LSP.JSON,
--
--     -- Scripting
--     C.LSP.PYTHON,
--
--     -- Go
--
--     -- Rust
--     C.LSP.RUST,
--
-- }

--------------------------------------------------------------------------------
-- Per-Server Configuration Overrides
--------------------------------------------------------------------------------
--
-- Each entry is a function: function(capabilities) -> nil
-- The function is expected to call lspconfig[server].setup(...)
-- with the provided capabilities table merged in.
--------------------------------------------------------------------------------

M.handlers = {

    --------------------------------------------------------------------------
    -- Lua Language Server
    --------------------------------------------------------------------------
    --
    -- Suppresses the "undefined global `vim`" diagnostic that fires
    -- inside Neovim config files.
    --------------------------------------------------------------------------

    [C.LSP.LUA] = function(capabilities)

        require("lspconfig").lua_ls.setup({

            capabilities = capabilities,

            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.fn.expand("$VIMRUNTIME/lua"),
                            vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                            vim.fn.stdpath("config") .. "/lua",
                        },
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },

        })

    end,

    --------------------------------------------------------------------------
    -- TailwindCSS
    --------------------------------------------------------------------------
    --
    -- Extended filetypes cover all templating contexts where Tailwind
    -- classes may appear, including JSX, TSX, and raw HTML/CSS.
    --------------------------------------------------------------------------

    [C.LSP.TAILWIND] = function(capabilities)

        require("lspconfig").tailwindcss.setup({

            capabilities = capabilities,

            filetypes = {
                "html",
                "css",
                "scss",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "tsx",
                "jsx",
            },

        })

    end,

    --------------------------------------------------------------------------
    -- Emmet
    --------------------------------------------------------------------------
    --
    -- Emmet LSP provides HTML/CSS abbreviation expansion.
    -- Enabled for HTML, CSS, and JSX/TSX templating contexts.
    --------------------------------------------------------------------------

    [C.LSP.EMMET] = function(capabilities)

        require("lspconfig").emmet_ls.setup({

            capabilities = capabilities,

            filetypes = {
                "html",
                "css",
                "scss",
                "javascriptreact",
                "typescriptreact",
                "tsx",
                "jsx",
            },

        })

    end,

}

return M
