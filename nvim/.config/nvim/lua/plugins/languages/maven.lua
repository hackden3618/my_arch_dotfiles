--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/maven.lua
--
-- Purpose:
--   Plugin specification for the Maven build tool integration.
--
-- Subsystem:  Languages › Java › Maven
--
-- Responsibilities:
--   • Register Maven keymaps when editing Java or XML files.
--   • Delegate all keymap logic to config/maven.lua.
--
-- Notes:
--   Maven has no dedicated Neovim plugin. The integration is purely
--   terminal-based (split + term mvn ...). Rather than hijacking a real
--   plugin spec, we use an `init` hook on the nvim-jdtls spec to ensure
--   Maven keymaps are registered alongside Java support.
--
--   The `init` function runs before the plugin loads (at Neovim startup
--   if the plugin's lazy triggers fire, or at require time). Using it on
--   a VeryLazy event ensures it runs early without coupling to a specific
--   Java buffer.
--
--   A FileType autocmd fires config() only for java/xml buffers, which
--   means Maven keymaps are registered exactly when needed and not before.
--------------------------------------------------------------------------------

return {

    "mfussenegger/nvim-jdtls",

    -- Reuse the same plugin identity as java.lua.
    -- Lazy.nvim merges multiple specs for the same plugin automatically.
    -- This spec adds only the Maven ft-triggered config on top.
    optional = true,

    ft = { "java", "xml" },

    config = function()
        require("plugins.languages.config.maven").setup()
    end,

}
