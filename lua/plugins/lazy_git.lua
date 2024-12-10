-- remember to install the lazygit dependency
-- choco install lazygit
vim.g.lazygit_on_exit_callback = function ()
    vim.cmd(":Neotree toggle")
    vim.cmd(":Neotree toggle")
end

return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	keys = {
		{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
}
