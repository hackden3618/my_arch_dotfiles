--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/harpoon.lua
--
-- Purpose:
--   Plugin specification for the File Navigation adapter.
--
-- Subsystem:  Editor › Navigation
-- Adapter:    harpoon2 (ThePrimeagen/harpoon, branch: harpoon2)
--
-- Responsibilities:
--   • Declare harpoon2 and plenary.nvim as dependencies.
--   • Lazy-load on the keymaps that open the harpoon menu or mark files.
--   • Delegate configuration and keymaps to the config function.
--
-- Notes:
--   UPGRADE FROM HARPOON v1 → HARPOON2:
--   Harpoon v1 is no longer maintained. Harpoon2 is a complete rewrite
--   with a new API. Key differences:
--
--     v1 (deprecated):
--       require("harpoon.mark").add_file()
--       require("harpoon.ui").toggle_quick_menu()
--
--     v2 (current):
--       local harpoon = require("harpoon")
--       harpoon:list():add()
--       harpoon.ui:toggle_quick_menu(harpoon:list())
--
--   The branch "harpoon2" is specified to pin to the new API.
--   plenary.nvim is required as a dependency.
--
--   Keymaps:
--     <S-m>    → Mark / add current file to harpoon list
--     <Tab>    → Toggle harpoon quick menu
--     <C-h/j/k/l> → Jump to files 1–4 in harpoon list
--------------------------------------------------------------------------------

return {

    "ThePrimeagen/harpoon",

    branch = "harpoon2",

    event = "VeryLazy",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    config = function()

        local harpoon = require("harpoon")
        local km      = require("core.keymaps")

        -- Initialize harpoon2
        harpoon:setup()

        -- Add current file to the harpoon list
        km.n("<S-m>", function()
            harpoon:list():add()
        end, "Harpoon: Mark File")

        -- Open the harpoon quick-menu
        km.n("<Tab>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, "Harpoon: Toggle Menu")

        -- Jump to files 1–4 by position
        -- Using <C-1/2/3/4> avoids conflicts with window navigation (<C-h/j/k/l>)
        km.n("<C-1>", function() harpoon:list():select(1) end, "Harpoon: File 1")
        km.n("<C-2>", function() harpoon:list():select(2) end, "Harpoon: File 2")
        km.n("<C-3>", function() harpoon:list():select(3) end, "Harpoon: File 3")
        km.n("<C-4>", function() harpoon:list():select(4) end, "Harpoon: File 4")

        -- Navigate prev/next in the list without the menu
        km.n("<C-S-p>", function() harpoon:list():prev() end, "Harpoon: Previous")
        km.n("<C-S-n>", function() harpoon:list():next() end, "Harpoon: Next")

    end,

}
