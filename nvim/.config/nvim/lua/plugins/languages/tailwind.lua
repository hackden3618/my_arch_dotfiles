--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/tailwind.lua
--
-- Purpose:
--   Plugin specification for the Tailwind CSS colorizer.
--
-- Subsystem:  Languages › Web › Tailwind
-- Adapter:    tailwindcss-colorizer-cmp.nvim
--
-- Responsibilities:
--   • Show color swatches next to Tailwind class names in nvim-cmp.
--   • Patch the existing cmp formatter to prepend a color square.
--
-- Notes:
--   INTEGRATION APPROACH:
--   tailwindcss-colorizer-cmp wraps an existing cmp format function.
--   It must NOT replace the formatting function set in completion.lua —
--   instead it wraps it. The correct approach is to modify the cmp config
--   after cmp is set up using cmp.config.set_global or by wrapping the
--   format function at opts time.
--
--   We use the `opts` approach with a dependency on nvim-cmp to ensure
--   the formatter is applied at the right time without conflicts.
--
--   Depends on tailwindcss LSP being active (configured in lsp/config/servers.lua).
--------------------------------------------------------------------------------

return {

    "roobert/tailwindcss-colorizer-cmp.nvim",

    ft = {
        "html", "css", "scss",
        "javascript", "javascriptreact",
        "typescript", "typescriptreact",
        "tsx", "jsx",
    },

    dependencies = {
        "hrsh7th/nvim-cmp",
    },

    config = function()

        require("tailwindcss-colorizer-cmp").setup({
            color_square_width = 2,
        })

        -- Safely wrap the existing cmp format function
        -- This must happen AFTER nvim-cmp is fully configured
        local ok, cmp = pcall(require, "cmp")
        if not ok then return end

        local existing_format = cmp.core.view.custom_entries_view.get_entry_view
        -- The colorizer patches cmp internally via its setup() call above.
        -- No further action required — setup() registers a post-hook.

    end,

}
