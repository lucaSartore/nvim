-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("omnisharp",{
        capabilities = capabilities,
        settings = {
            csharp = {

                  RoslynExtensionsOptions = {
                    enableAnalyzersSupport= true
                  },
                  FormattingOptions= {
                    enableEditorConfigSupport= true,
                  }
            }
        }
    })
    vim.lsp.enable("omnisharp")
end

return M
