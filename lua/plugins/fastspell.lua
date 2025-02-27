return {
	"lucaSartore/fastspell.nvim",
	config = function()
		local fastspell = require("fastspell")

		fastspell.setup()

		vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter", "WinScrolled" }, {
			callback = function(_)
				local first_line = vim.fn.line("w0")
				local last_line = vim.fn.line("w$")
				fastspell.sendSpellCheckRequest(first_line, last_line)

				-- local end_line = vim.api.nvim_buf_line_count(0)
				-- spell_check_request.sendSpellCheckRequest(0, end_line)
			end,
		})
	end,
}
