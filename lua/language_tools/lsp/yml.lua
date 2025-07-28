-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require('lspconfig').yamlls.setup {
      settings = {
        yaml = {
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          },
        },
      }
    }
end

return M
