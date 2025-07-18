-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    require("lspconfig").omnisharp.setup({
        capabilities = capabilities,
        cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        root_dir = require("lspconfig").util.root_pattern("*.csproj", "*.sln"),
    })
end

return M
