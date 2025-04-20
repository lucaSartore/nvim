-- Python DAP configuration (debugpy)
local dap = require("dap")
local M = {}

function M.setup()
    local mason_registry = require("mason-registry")
    local debugpy_path = mason_registry.get_package("debugpy"):get_install_path()
    
    dap.adapters.debugpy = {
        type = "executable",
        command = debugpy_path .. "\\venv\\Scripts\\python",
        args = { "-m", "debugpy.adapter" },
        detached = false,
        options = {
            source_filetype = "python",
        },
    }
    
    dap.configurations.python = {
        {
            type = "debugpy",
            request = "launch",
            name = "Launch file",
            cwd = "${fileDirname}",
            program = "${file}",
            pythonPath = vim.fn.exepath("python"),
        },
    }
end

return M