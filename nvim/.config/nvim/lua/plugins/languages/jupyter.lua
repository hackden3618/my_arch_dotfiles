return {
	{
		"benlubas/molten-nvim",
		build = ":UpdateRemotePlugins",
	},
	{
		"GCBallesteros/jupytext.nvim",
		opts = {
			style = "markdown", -- convert .ipynb to markdown for editing
			output_extension = "md",
			force_ft = "markdown",
		},
	},
}
