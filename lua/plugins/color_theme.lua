return {
	"navarasu/onedark.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		-- this is a comment
		require("onedark").setup({
			style = "darker",
			highlights = {
				-- ["@variable"] = { fg = "$cyan" },
				-- ["@comment"] = { fg = "#B0B0B0" },
				-- ["@lsp.type.comment"] = { fg = "#B0B0B0" },
				-- ["@punctuation.delimiter"] = { fg = "#DDDDDD" },
				-- ["@punctuation.bracket"] = { fg = "#DDDDDD" },
			},
		})
		require("onedark").load()
	end,
}
