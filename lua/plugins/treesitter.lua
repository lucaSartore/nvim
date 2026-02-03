return {
	"nvim-treesitter/nvim-treesitter",
    lazy = false,
	build = ":TSUpdate",
	dependencies = {
        -- required to make the mini-ai around function/class/block work
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        "LiadOz/nvim-dap-repl-highlights"
	},
	config = function()

        -- used to highlight the dap console
        require('nvim-dap-repl-highlights').setup()
		local configs = require("nvim-treesitter.config")
        require'nvim-treesitter'.setup {

          install_dir = vim.fn.stdpath('data') .. '/site'
        }

        local languages = {
            "c",
            "cpp",
            "lua",
            "javascript",
            "html",
            "python",
            "rust",
            "go",
            "markdown",
            "markdown_inline",
            "dap_repl",
            "haskell",
            "c_sharp"
        }


        vim.api.nvim_create_autocmd('FileType', {
          pattern = languages,
          callback = function() vim.treesitter.start() end,
        })

        require'nvim-treesitter'.install(languages)
	end,
}
