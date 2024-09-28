----------------- ToDo ------------------------------------
-- pass all check health
-- copilot
-- open folder / open recent folder
-- disable and enable global spelling
------------------ ToDo: Low priority ---------------------
-- lazy git command "e" to edit file not working
-- neo tree jump to folder/file that start with letter

-------------- cool ideas --------------------
-- eye tracker


-- if you are or not on windows os
vim.g.windows = true

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- enable nerd font for better icons, nerd font must be installed in the PC, and set as the default font for the terminal
vim.g.have_nerd_font = true

-- update time is used to determine after how long worlds are highlighted
vim.o.updatetime = 500

-- 4 spaces as tab width
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- spell checker
vim.opt.spelllang = "en_us,it"
vim.opt.spell = true
vim.opt.spelloptions = "camel"

-- to quickly move up and down (similar to <C-b> and <C-f> but more intuitive keybindings for me)
vim.api.nvim_set_keymap("n", "<C-k>", "10k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "10j", { noremap = true, silent = true })

-- escape from terminal mode
vim.api.nvim_set_keymap("t", "<esc>", "", {
	noremap = true,
	silent = true,
	callback = function()

        -- if i am inside lazy git i don't want to remap the key
		local buffer_name = vim.api.nvim_buf_get_name(0)
		if string.sub(buffer_name, -8) == ":lazygit" then
			local key = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
			vim.api.nvim_feedkeys(key, "n", false)
			return
		end

		local key = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
		vim.api.nvim_feedkeys(key, "n", false)
	end,
})

-- window management with tap key
vim.api.nvim_set_keymap("n", "<tab>", "<C-w>", { noremap = true, silent = false })

vim.wo.relativenumber = true
vim.o.number = true

-- always keep a column of space to the left for brake-points and other hinting elements
vim.opt.signcolumn = "yes:1"

-- backspace to delete
vim.api.nvim_set_keymap("i", "<C-H>", "<C-W>", { noremap = true })

-- to maintain the selection after indenting
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true })

-- to avoid having to do :noh every time you are done searching
vim.api.nvim_create_autocmd("CmdlineEnter", {
	pattern = { "/", "?" },
	callback = function()
		vim.opt.hlsearch = true
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	pattern = { "/", "?" },
	callback = function()
		vim.opt.hlsearch = false
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 250 })
	end,
})

-- delete without yank
vim.api.nvim_set_keymap("n", "D", '"_d', { noremap = true, silent = false })

-- mode to previous buffer
vim.api.nvim_set_keymap("n", "<tab><tab>", ":b# <CR>", { noremap = true, silent = false })

-- use system clipboard
vim.opt.clipboard = "unnamedplus"

-- left and right wrapping
vim.opt.whichwrap = "b,s,h,l"

-- using powershell as default terminal
-- vim.opt.shell='powershell.exe'
-- vim.cmd('set shellcmdflag="-c"')

require("config.lazy")

-- vim.print(string.format("elapsed time: %.2f\n", os.clock() - time))
