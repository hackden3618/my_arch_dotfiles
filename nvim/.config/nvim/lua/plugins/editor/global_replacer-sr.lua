return {
    "p-nerd/sr.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("sr").setup({ keymap = "<leader>sr" })
    end
}
