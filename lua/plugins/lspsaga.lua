
return {
    "glepnir/lspsaga.nvim",

	config = function()
        local saga = require('lspsaga')
        saga.setup({})
        vim.api.nvim_set_keymap('n', 'gh', '<cmd>Lspsaga hover_doc<CR>', { silent = true, noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>pt', '<cmd>Lspsaga peek_type_definition<CR>', { silent = true, noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>gt', '<cmd>Lspsaga goto_type_definition<CR>', { silent = true, noremap = true })
	end,
}
