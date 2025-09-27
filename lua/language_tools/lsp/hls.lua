-- Haskell LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("hls",{
        capabilities = capabilities,
        settings = {
            haskell = {
                formattingProvider = "ormolu",
                checkProject = true,
            }
        }
    })
    vim.lsp.enable("hls")
end

return M
