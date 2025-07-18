return {
    "gbprod/substitute.nvim",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },

    config = function ()
        require('substitute').setup()

        -- default (non used) keybindings for LSP
        vim.keymap.del("n", "grn")
        vim.keymap.del("n", "gra")
        vim.keymap.del("n", "grr")
        vim.keymap.del("n", "gri")
        vim.keymap.del("n", "grt")

        vim.keymap.set("n", "gr", require('substitute').operator, { noremap = true })
    end
}
