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

			-- Use enabled_languages configuration for tool installation
			local enabled_languages = require("language_tools.enabled_languages")

			-- Common tools always installed
			local ensure_installed = {
				-- Common tools
				"cspell",
			}

			-- LSP servers based on enabled languages
			if enabled_languages.is_language_enabled("lua") then
				table.insert(ensure_installed, "lua_ls")
				table.insert(ensure_installed, "stylua") -- Lua formatter
			end

			if enabled_languages.is_language_enabled("rust") then
				table.insert(ensure_installed, "rust_analyzer")
				table.insert(ensure_installed, "rustfmt") -- Rust formatter
				table.insert(ensure_installed, "codelldb") -- Rust (and all llvm stuff) debugger
			end

			if enabled_languages.is_language_enabled("python") then
				table.insert(ensure_installed, "pyright")
				table.insert(ensure_installed, "black") -- Python formatter
				table.insert(ensure_installed, "debugpy") -- Python debugger
			end

			if enabled_languages.is_language_enabled("javascript") then
				table.insert(ensure_installed, "ts_ls")
				table.insert(ensure_installed, "biome") -- JavaScript/TypeScript formatter
			end

			if enabled_languages.is_language_enabled("go") then
				table.insert(ensure_installed, "gopls")
				table.insert(ensure_installed, "gofumpt") -- Golang formatter
				table.insert(ensure_installed, "go-debug-adapter")
			end

			-- if enabled_languages.is_language_enabled("haskell") then
			-- 	table.insert(ensure_installed, "hls")
			-- 	table.insert(ensure_installed, "ormolu") -- Haskell formatter
			-- 	table.insert(ensure_installed, "haskell-debug-adapter")
			-- end

            if enabled_languages.is_language_enabled("csharp") and vim.fn.has("Win32") == 1 then
				table.insert(ensure_installed, "omnisharp")
            end

            if enabled_languages.is_language_enabled("yml") then
				table.insert(ensure_installed, "yaml-language-server")
            end

            if enabled_languages.is_language_enabled("nix") then
				table.insert(ensure_installed, "nil")
				table.insert(ensure_installed, "nixfmt")
            end

            if enabled_languages.is_language_enabled("cpp") then
                -- on linux this is installed with nix
                if vim.fn.has("Win32") then
				    table.insert(ensure_installed, "clangd")
                end
                -- this may be already installed by rust
                if not enabled_languages.is_language_enabled("rust") then
				    table.insert(ensure_installed, "codelldb")
                end
            end

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
