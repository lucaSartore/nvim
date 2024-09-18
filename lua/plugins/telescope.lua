-- note to self: live grep won't work without the "rg" shell command
-- on window this command is not installed by default, and can be installed with:
--      choco install ripgrep
-- the "fd" command can enhance the experience as well
--      choco install fd
return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- make telescope fuzzy finder for bad typing
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		"nvim-telescope/telescope-live-grep-args.nvim",
	},
	config = function()
		require("telescope").setup({
			extensions = {
				-- use telescope finder for other neovim stuff
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
			pickers = {
				buffers = {
					sort_mru = true, -- Sort buffers by most recent usage
					-- ignore_current_buffer = true, -- Ignore the current buffer in the list
					sort_lastused = true,
					initial_mode = "normal",
				    path_display = { "tail" },
				},
			}
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")
		pcall(require("telescope").load_extension, "live_grep_args")

		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")
		local extensions = require("telescope").extensions
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set(
			"n",
			"<leader>/",
			builtin.current_buffer_fuzzy_find,
			{ desc = "[/] Fuzzily search in current buffer" }
		)
		vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "[S]earch [S]pelling" })
		-- vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		--
		-- Example of a valid search
		--
		--      --no-ignore: include all files (aka stop excluding git ignored)
		--      "keymap": search for the world keymap
		--      nvim: search inside the folder nvim
		--      -g "**/lua/**" the file must be inside a folder named lua
		--          *: match any file name (or partial file name)
		--          **: match any sequence of folders
		--      -g "!telesc*": excluding all files that have a name that start with "telesc"
		--      --no-ignore "keymap" -tlua nvim -g "**/lua/**" -g "!telesc*"
		vim.keymap.set("n", "<leader>sg", extensions.live_grep_args.live_grep_args, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })

		-- life grep in open files
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({ live_grep_args = true, prompt_title = "Live Grep in Open Files" })
		end, { desc = "[S]earch [/] in Open Files" })

		-- searching Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })

		vim.keymap.set("n", "<leader>sp", function()
			builtin.find_files({ cwd = "C:\\PROROB" })
		end, { desc = "[S]earch [P]ROROB folder" })
	end,
}
