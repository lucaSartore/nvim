
local search
if vim.fn.has('win32') == 1 then
    search = {
        myconda = {
            command = "$FD python.exe$ C:/tools/miniconda3/envs --no-ignore-vcs --full-path -a -E Lib",
        },
        myconda2 = {
            command = "$FD python.exe$ C:/Users/lucas/.conda/envs --no-ignore-vcs --full-path -a -E Lib",
        },
        all_envs_in_path = {
            command = "where python"
        }
    }
else
    search = {}
end


return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  lazy = false,
  branch = "regexp",
  opts = {
        search = search
  },
}
