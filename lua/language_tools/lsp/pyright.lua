-- Python LSP (Pyright) configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require("lspconfig").pyright.setup({
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "standard", -- options: ["off", "basic", "standard", "strict"]
                },
            },
        },
    })
end

return M