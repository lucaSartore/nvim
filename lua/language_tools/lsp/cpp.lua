-- Go LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("clangd",{
        capabilities = capabilities,
        settings = {
        },
    })
    vim.lsp.enable("clangd")
end

return M
