return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
            -- most features have been removed since i don't use them
            -- and key maps some times interact poorly with each others
			keymaps = {
				-- insert = "<C-g>s",
				-- insert_line = "<C-g>S",
				normal = "ys",
				-- normal_cur = "yss",
				-- normal_line = "yS",
				-- normal_cur_line = "ySS",
				-- visual = "S",
				-- visual_line = "gS",
				delete = "ds",
				change = "cs",
				-- change_line = "cS",
			},
		})
	end,
}
