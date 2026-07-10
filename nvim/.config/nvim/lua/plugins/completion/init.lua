--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/init.lua
--
-- Purpose:
--   Completion subsystem manifest.
--
-- Responsibilities:
--   • Register all Completion plugin specifications for Lazy.nvim.
--
-- Subsystems registered here:
--   • Completion Engine → nvim-cmp     (completion menu + sources)
--   • Snippet Engine   → LuaSnip      (snippet expansion)
--   • AI Engine        → codeium.nvim (AI-powered suggestions)
--
-- Notes:
--   Plugin specifications are intentionally separate from their
--   implementation details. No configuration logic lives here.
--
--   nvim-autopairs is declared as a dependency of nvim-cmp to ensure
--   correct initialization order. Its plugin spec is here to make it
--   visible in the subsystem.
--------------------------------------------------------------------------------

return {

    require("plugins.completion.luasnip"),

    require("plugins.completion.codeium"),

    require("plugins.completion.cmp"),

    -- Autopairs: auto-close brackets, quotes, parentheses.
    -- Registered here since it integrates with nvim-cmp.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts  = {
            check_ts = true,  -- Use treesitter for smarter pairing
        },
    },

}
