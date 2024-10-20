return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
        -- required to make the mini-ai around function/class/block work
		"nvim-treesitter/nvim-treesitter-textobjects",
        "LiadOz/nvim-dap-repl-highlights"
	},
	config = function()

        -- used to highlight the dap console
        require('nvim-dap-repl-highlights').setup()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c",
				"lua",
				"javascript",
				"html",
				"python",
				"rust",
				"go",
				"markdown",
				"markdown_inline",
                "dap_repl",
                "haskell"
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
