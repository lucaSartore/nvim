return {
	"lucaSartore/fastspell.nvim",
	config = function()
		local fastspell = require("fastspell")

		fastspell.setup()

		vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI"}, {
			callback = function(_)
                local current_row = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
                local first_line = current_row-2
                local last_line = current_row+1
                fastspell.sendSpellCheckRequest(first_line, last_line)
			end,
		})
	end,
}
