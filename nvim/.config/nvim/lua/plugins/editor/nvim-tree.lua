--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/nvim-tree.lua
--
-- Purpose:
--   Plugin specification for the Explorer Engine adapter.
--
-- Subsystem:  Editor › Explorer Engine
-- Adapter:    nvim-tree.lua
--
-- Responsibilities:
--   • Declare nvim-tree and nvim-web-devicons as dependencies.
--   • Lazy-load on the keymap that opens the tree.
--   • Delegate all configuration to config/explorer.lua.
--
-- Notes:
--   nvim-tree replaces netrw as the file exploration interface.
--   It is loaded lazily and only initializes when <C-n> is pressed.
--------------------------------------------------------------------------------

return {

    "nvim-tree/nvim-tree.lua",

    keys = {
        { "<C-n>", desc = "Toggle File Explorer" },
    },

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    init = function()
        -- Load nvim-tree automatically if Neovim is opened with a directory
        -- e.g. `nvim .`
        if vim.fn.argc(-1) == 1 then
            local stat = vim.uv.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
                require("lazy").load({ plugins = { "nvim-tree.lua" } })
            end
        end
    end,

    config = function()
        require("plugins.editor.config.explorer").setup()
    end,

}
