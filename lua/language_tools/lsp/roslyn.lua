-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("roslyn_ls",{
        capabilities = capabilities,
        settings = {
        }
    })
    vim.lsp.enable("roslyn_ls")
end

return M
