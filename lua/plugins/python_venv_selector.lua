
vim.api.nvim_create_user_command('VenvSelectorReset', function()
    require("venv-selector").python()
end, {})

local search
if vim.fn.has('win32') == 1 then
    search = {
        myconda = {
            command = "fd \\\\python.exe$ C:/tools/miniconda3/envs --no-ignore-vcs --full-path -a -E Lib",
            type = "anaconda"
        },
        myconda2 = {
            command = "fd \\\\python.exe$ C:/Users/lucas/.conda/envs --no-ignore-vcs --full-path -a -E Lib",
            type = "anaconda"
        },
        all_envs_in_path = {
            command = "fd \\\\python.exe$ C:/PROROB/bin_srv/Python311 --no-ignore-vcs --full-path -a -E Lib",
        }
    }
else
    search = {}
end


return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap", "lucaSartore/nvim-dap-python", --optional
    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  lazy = false,
  branch = "regexp", -- reminder: the plugin has being rewritten entirely, and is in the new branch

  opts = {
        search = search
  },
}
