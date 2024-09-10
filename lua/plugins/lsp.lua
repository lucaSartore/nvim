-- Function to show the full error message in a floating window
function show_diagnostics()
	local opts = {
		focusable = false,
		close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
		border = "rounded",
		source = "always",
		prefix = "",
	}
	vim.diagnostic.open_float(nil, opts)
end

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
			-- lsp attach event
			vim.api.nvim_create_autocmd("LspAttach", {

				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- wrapper function to create key bindings
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					------------------------------------- KEYBINDINGS --------------------------------------------------------
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gu", require("telescope.builtin").lsp_references, "[G]oto [U]sage")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", ":Lspsaga code_action<CR>", "[C]ode [A]ction")
					map("<leader>pu", ":Lspsaga incoming_calls<CR>", "[P]eack [U]sage")
					map("<leader>pd", ":Lspsaga peek_definition<CR>", "[P]eack [D]efinition")

					------------------------------- HIGHLIGHT ON HOVER
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end
					------------------------ toggle inline suggestions ---------------------------------------
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Keybinding to show the full diagnostic message
			vim.api.nvim_set_keymap(
				"n",
				"ge",
				"<cmd>lua show_diagnostics()<CR>",
				{ noremap = true, silent = true, desc = "Show error message" }
			)

			-- capabilities of local lsp server, used to comunicate with the language specific lsp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- list of LSPs
			-- some configurations options can be passed, to know more about the configurations check init.lua of kickstarter.nvim
			local language_servers = {
				lua_ls = {},
				rust_analyzer = {},
				omnisharp = {},
				tsserver = {},
                -- ts_ls = {},
                gopls = {},
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "standard", -- standard type checking
								-- typeCheckingMode = "strict", -- check for type hint as well
							},
						},
					},
				},
			}

			-- reminder: use :Mason to see/update the installed LSPs/DAPs
			require("mason").setup()

			-- installing all Mason stuff
			local ensure_installed = vim.tbl_keys(language_servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"black", -- python formatter
				"debugpy", -- python debugger
                "biome", -- javascript formatter
                "gofumpt", -- golang formatter
                "go-debug-adapter",
                "codelldb", -- rust (and all llvm stuff) debugger
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- setting up the attaching the LSP with correct capabilities and server settings
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
                        -- small workaround as tsserver is no longer supported
                        if server_name == "tsserver" then
                            server_name = "ts_ls"
                        end

						local server = language_servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-------------------------- CODE FORMATTER -------------------------------------------------------
	{
		"mhartington/formatter.nvim",

		config = function()
			require("formatter").setup({
				logging = false,
				filetype = {
					lua = { require("formatter.filetypes.lua").stylua },
					python = { require("formatter.filetypes.python").black },
                    javascript = { require("formatter.filetypes.javascript").biome },
                    go = { require("formatter.filetypes.go").gofumpt }
				},
			})
		end,
	},
}
