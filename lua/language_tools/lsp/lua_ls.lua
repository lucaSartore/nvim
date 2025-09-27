-- Lua Language Server configuration
local M = {}

---@param capabilities table LSP capabilities
function M.setup(capabilities)
    vim.lsp.config("lua_ls",{
        capabilities = capabilities,
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.stdpath("config") .. "/lua"] = true,
                    },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    })
    vim.lsp.enable("lua_ls")
end

return M
