return {
	----------------------------------- LANGUAGE SERVER PROTOCOL (LSP) ---------------------------
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/nvim-cmp",
			"glepnir/lspsaga.nvim",
		},
		config = function()
			-- Configure all LSP related components
			require("language_tools.lsp").setup()
			
			local ensure_installed = {
				-- LSP servers
				"lua_ls",
				"rust_analyzer",
				"pyright",
				"tsserver",
				"gopls",
				"hls",
				
				-- Formatters and linters
				"stylua", -- Used to format Lua code
				"black", -- python formatter
				"debugpy", -- python debugger
				"biome", -- javascript formatter
				"gofumpt", -- golang formatter
				"ormolu", -- haskell formatter
				"rustfmt", -- rust formatter
				
				-- Debug adapters
				"go-debug-adapter",
				"codelldb", -- rust (and all llvm stuff) debugger
				"haskell-debug-adapter",
				
				-- Other tools
				"cspell",
			}

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
		end,
	},

	-------------------------- CODE FORMATTER -------------------------------------------------------
	{
		"mhartington/formatter.nvim",

		config = function()
			-- Initialize the formatter modules
			require("language_tools.formatter").setup()
		end,
	},
}
