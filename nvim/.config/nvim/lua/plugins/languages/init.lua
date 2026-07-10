--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/init.lua
--
-- Purpose:
--   Languages subsystem manifest.
--
-- Responsibilities:
--   • Register all language-specific plugin specifications for Lazy.nvim.
--
-- Languages registered here:
--   • Java     → nvim-jdtls (LSP lifecycle, DAP, refactoring, runners)
--   • Maven    → terminal-based mvn commands (<leader>m)
--   • Web      → toggleterm (live-server, C runner, Python runner)
--   • Tailwind → tailwindcss-colorizer-cmp (color swatches in completion)
--   • Prisma   → vim-prisma + treesitter parser (schema highlighting)
--
-- Notes:
--   Plugin specifications are intentionally separate from their
--   implementation details. No configuration logic lives here.
--
--   The maven.lua spec uses plenary.nvim as its plugin entry point
--   since Maven itself has no dedicated Neovim plugin.
--------------------------------------------------------------------------------

return {

    require("plugins.languages.java"),

    require("plugins.languages.maven"),

    require("plugins.languages.web"),

    require("plugins.languages.tailwind"),

    require("plugins.languages.prisma"),

}
