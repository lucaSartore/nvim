-- Rust Analyzer LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require("lspconfig").rust_analyzer.setup({
        capabilities = capabilities,
        settings = {
            ['rust-analyzer'] = {
                checkOnSave = {
                    command = "clippy",
                },
                diagnostics = {
                    enable = true,
                },
            }
        }
    })
end

return M