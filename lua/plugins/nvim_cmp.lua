return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
		"L3MON4D3/LuaSnip",
		"glepnir/lspsaga.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local saga = require("lspsaga")

		vim.opt.completeopt = { "menu", "menuone", "noselect" }

        -- return the timestamp of the last (or second last if inverse_index = 1) undo breaks set
		local last_edit_ts = function(inverse_index)
			local tree = vim.fn.undotree().entries
            if #tree <= inverse_index then return 0 end
			return tree[#tree-inverse_index].time
		end

        -- when an autocompletion is performed we set an undo breaks first, so that if I undo I don't loose the text I manually typed
		local keys = vim.api.nvim_replace_termcodes("<C-g>u", true, false, true)
		local confirm_fn = cmp.mapping.confirm({ select = true })
		local last_tab_undo_ts = 0
		local confirm_fn_with_undo_checkpoint = function(fallback)
			if cmp.visible() then
				vim.api.nvim_feedkeys(keys, "i", false)
				last_tab_undo_ts = last_edit_ts(0)
				confirm_fn(fallback)
			else
				fallback()
			end
		end

        -- when I undo, if the last break was set by the nvim_cmp autocompletion I also perform a jump
        -- to the previous cursor position (this is because if the autocompletion has automatically added
        -- some imports, the cursor would be teleported at the top of the file)
		vim.keymap.set("n", "u", function()
			if last_edit_ts(1) == last_tab_undo_ts then
				return vim.api.nvim_replace_termcodes("u`'", true, false, true)
			else
				return vim.api.nvim_replace_termcodes("u", true, false, true)
			end
		end, { expr = true })

		cmp.setup({

			-- REQUIRED - you must specify a snippet engine
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},

			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.scroll_docs(-4),
				["<C-j>"] = cmp.mapping.scroll_docs(4),
				["<Tab>"] = confirm_fn_with_undo_checkpoint,
				["<CR>"] = confirm_fn_with_undo_checkpoint,
			}),

			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
		saga.setup({})

		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})
	end,
}
