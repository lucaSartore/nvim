-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("yamlls",{
      settings = {
        yaml = {
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          },
        },
      }
    })
    vim.lsp.enable("yamlls")
end

return M
