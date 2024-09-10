
return {
    "glepnir/lspsaga.nvim",

	config = function()
        local saga = require('lspsaga')
        saga.setup({})
        vim.api.nvim_set_keymap('n', 'gh', '<cmd>Lspsaga hover_doc<CR>', { silent = true, noremap = true })
	end,
}
