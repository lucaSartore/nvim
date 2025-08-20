local M = {}

function M.setup(capabilities)
    require("lspconfig").nil_ls.setup({
        capabilities = capabilities,
        -- settings = { }
    })
end

return M
