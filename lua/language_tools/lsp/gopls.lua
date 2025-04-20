-- Go LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require("lspconfig").gopls.setup({
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true,
            },
        },
    })
end

return M