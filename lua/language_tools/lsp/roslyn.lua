-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("roslyn-ls",{
        capabilities = capabilities,
        settings = {
        }
    })
    vim.lsp.enable("roslyn-ls")
end

return M
