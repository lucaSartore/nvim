local M = {}

function M.setup(capabilities)
    vim.lsp.config("nil_ls",{
        capabilities = capabilities,
        -- settings = { }
    })
    vim.lsp.enable("nil_ls")
end

return M
