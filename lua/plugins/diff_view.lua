return {
    "sindrets/diffview.nvim",
    config = function ()
		vim.api.nvim_set_keymap("n", "<leader>gd", ":DiffviewOpen<cr>", { desc = "[G]ithub [D]iff" })
		vim.api.nvim_set_keymap("n", "<leader>gD", ":DiffviewOpen", { desc = "[G]ithub [D]iff with options" })
    end
}
