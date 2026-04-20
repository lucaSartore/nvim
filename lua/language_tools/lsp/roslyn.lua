-- C# lsp configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)

    local highlight_links = {
        ["@lsp.type.recordClass.cs"] = "@type",
        ["@lsp.type.recordStruct.cs"] = "@type",
        ["@lsp.type.interface.cs"] = "@type",
        ["@lsp.type.class.cs"] = "@type",
        ["@lsp.type.struct.cs"] = "@type",
        ["@lsp.type.enum.cs"] = "@type",
        ["@lsp.type.delegate.cs"] = "@type",
        ["@lsp.type.extensionMethod.cs"] = "@function.method",
        ["@lsp.type.field.cs"] = "@variable.member",
        ["@lsp.type.property.cs"] = "@variable.member",
        ["@lsp.type.event.cs"] = "@variable.member",
        ["@lsp.mod.readonly.cs"] = "@constant",
    }

    for group, link in pairs(highlight_links) do
        vim.api.nvim_set_hl(0, group, { link = link, default = true })
    end

    vim.lsp.config("roslyn_ls",{
        capabilities = capabilities,
        settings = {
        }
    })
    vim.lsp.enable("roslyn_ls")
end

return M
