--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/jupyter.lua
--
-- Purpose:
--   Plugin specification for Jupyter Notebooks & Machine Learning subsystem.
--
-- Subsystem:  Languages › Jupyter
-- Adapters:   molten-nvim, jupytext.nvim, image.nvim
--
-- Responsibilities:
--   • Declare jupytext.nvim for transparent .ipynb ↔ # %% Python file conversion.
--   • Declare 3rd/image.nvim for Kitty GPU graphics protocol inline plot rendering.
--   • Declare molten-nvim for interactive Jupyter kernel execution.
--   • Delegate all configuration to config/jupyter.lua.
--------------------------------------------------------------------------------

return {

    {
        "GCBallesteros/jupytext.nvim",
        lazy = false,
        config = function()
            require("plugins.languages.config.jupyter").setup_jupytext()
        end,
    },

    {
        "3rd/image.nvim",
        build = false,
        event = "VeryLazy",
        config = function()
            require("plugins.languages.config.jupyter").setup_image()
        end,
    },

    {
        "benlubas/molten-nvim",
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        init = function()
            require("plugins.languages.config.jupyter").setup_molten_globals()
        end,
        config = function()
            require("plugins.languages.config.jupyter").setup_molten()
        end,
    },

}
