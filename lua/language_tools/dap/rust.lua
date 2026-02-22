-- Rust DAP configuration
local dap = require("dap")
local M = {}

local last_input = nil

function M.setup()
    
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = { "--port", "${port}" },
        },
    }

    dap.configurations.rust = {
        {
            name = "Rust debug",
            type = "codelldb",
            request = "launch",
            showDisassembly = "never",
            program = function()
                local cwd = vim.fn.getcwd()
                local project_name = vim.fn.fnamemodify(cwd, ':t')
                local default = last_input or cwd .. "/target/debug/" .. project_name
                last_input = vim.fn.input("Path to executable: ", default, "file")
                return last_input
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
end

return M
