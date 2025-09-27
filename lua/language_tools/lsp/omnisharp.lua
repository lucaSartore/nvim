-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("omnisharp",{
        capabilities = capabilities,
    })
    vim.lsp.enable("omnisharp")
end

return M
