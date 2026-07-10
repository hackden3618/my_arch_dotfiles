--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/java.lua
--
-- Purpose:
--   Plugin specification for the Java language subsystem.
--
-- Subsystem:  Languages › Java
-- Adapter:    nvim-jdtls
--
-- Responsibilities:
--   • Declare nvim-jdtls and its dependencies.
--   • Trigger exclusively on Java file type.
--   • Delegate all JDTLS configuration to config/java.lua.
--
-- Notes:
--   WHY nvim-jdtls INSTEAD OF lspconfig jdtls?
--   The lspconfig approach cannot handle JDTLS's lifecycle requirements:
--     • Per-project workspace directories
--     • DAP extension bundles
--     • jdtls.start_or_attach() vs standard lspconfig.setup()
--     • Lombok agent injection
--   nvim-jdtls wraps all of this correctly.
--
--   The FileType autocommand is created in the config function rather
--   than using ft = "java" at the plugin spec level because we need to
--   call jdtls.start_or_attach() on every relevant BufEnter too
--   (handled by jdtls itself when called on FileType).
--------------------------------------------------------------------------------

return {

    "mfussenegger/nvim-jdtls",

    ft = "java",

    dependencies = {
        "mfussenegger/nvim-dap",
        "williamboman/mason.nvim",
    },

    config = function()

        local jdtls_config = require("plugins.languages.config.java")

        vim.api.nvim_create_autocmd("FileType", {

            pattern  = "java",
            group    = vim.api.nvim_create_augroup("PDEJava", { clear = true }),
            desc     = "Start or reattach JDTLS for Java buffers",

            callback = function()
                local ok, config = pcall(jdtls_config.build_config)
                if ok then
                    require("jdtls").start_or_attach(config)
                else
                    require("core.logging").error(
                        "JDTLS config failed: " .. tostring(config),
                        "Java"
                    )
                end
            end,

        })

    end,

}
