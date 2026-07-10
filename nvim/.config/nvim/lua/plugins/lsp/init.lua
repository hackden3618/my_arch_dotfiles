--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/lsp/init.lua
--
-- Purpose:
--   LSP subsystem manifest.
--
-- Responsibilities:
--   • Register all LSP plugin specifications for Lazy.nvim.
--
-- Subsystems registered here:
--   • Language Intelligence Engine → nvim-lspconfig (server config)
--   • Mason                        → server installation
--   • Diagnostics Engine           → integrated inside lsp.lua
--   • Formatting Engine            → integrated inside lsp.lua
--
-- Notes:
--   Plugin specifications are intentionally separate from their
--   implementation details. No configuration logic lives here.
--------------------------------------------------------------------------------

return {

    require("plugins.lsp.lsp"),

}
