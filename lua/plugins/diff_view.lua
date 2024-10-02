return {
    "sindrets/diffview.nvim",
    config = function ()
		vim.api.nvim_set_keymap("n", "<leader>gd", ":DiffviewOpen<cr>", { desc = "[G]ithub [D]iff" })
        -- Examples of commands 
        -- :DiffviewOpen HEAD~4..HEAD~2
        -- :DiffviewOpen d4a7b0d
		vim.api.nvim_set_keymap("n", "<leader>gD", ":DiffviewOpen", { desc = "[G]ithub [D]iff with options" })
    end
}
