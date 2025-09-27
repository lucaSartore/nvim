-- Rust Analyzer LSP configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("rust_analyzer",{
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
    vim.lsp.enable("rust_analyzer")
end

return M
