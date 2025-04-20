-- Haskell LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require("lspconfig").hls.setup({
        capabilities = capabilities,
        settings = {
            haskell = {
                formattingProvider = "ormolu",
                checkProject = true,
            }
        }
    })
end

return M