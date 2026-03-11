return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
    require("nvim-surround").setup()
        vim.g.nvim_surround_no_normal_mappings = true
        vim.keymap.set("n", "ys", "<Plug>(nvim-surround-normal)", {
            desc = "Add a surrounding pair around a motion (normal mode)",
        })
        vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", {
            desc = "Delete a surrounding pair",
        })
        vim.keymap.set("n", "rs", "<Plug>(nvim-surround-change)", {
            desc = "Change a surrounding pair",
        })
	end,
}
