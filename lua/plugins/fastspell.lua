return {
	"lucaSartore/fastspell.nvim",

    build = function ()
        local base_path = vim.fn.stdpath("data") .. "/lazy/fastspell.nvim"
        local cmd = base_path .. "/lua/scripts/install." .. (vim.fn.has("win32") and "cmd" or "sh")
        vim.system({cmd})
    end,

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


        vim.api.nvim_set_keymap("n", "<leader>sc", "", {
            noremap = true,
            silent = true,
            desc = "Debug [S]pell [C]heck",
            callback = function()
                local buffer = vim.api.nvim_get_current_buf()
                local first_line = 0
                local last_line =vim.api.nvim_buf_line_count(buffer)
                fastspell.sendSpellCheckRequest(first_line, last_line)
            end,
        })

        vim.api.nvim_set_keymap("n", "<leader>si", "", {
            noremap = true,
            silent = true,
            desc = "Debug [S]pell [I]gnore",
            callback = function()
                fastspell.sendSpellCheckRequest(0,0)
            end,
        })



	end,
}
