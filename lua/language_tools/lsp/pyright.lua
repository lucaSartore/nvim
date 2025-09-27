-- Python LSP (Pyright) configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("pyright",{
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "standard", -- options: ["off", "basic", "standard", "strict"]
                },
            },
        },
    })
    vim.lsp.enable("pyright")
end

return M
