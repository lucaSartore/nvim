-- Haskell DAP configuration
local dap = require("dap")
local M = {}

---@class HaskellDebugConfig
---@field adapter table The adapter configuration
---@field configurations table[] List of debug configurations

function M.setup()
    local mason_registry = require("mason-registry")
    local haskelldbg = mason_registry.get_package("haskell-debug-adapter")
    local haskell_cmd = haskelldbg:get_install_path() .. "/haskell-debug-adapter"

    dap.adapters.ghc = {
        type = "executable",
        command = haskell_cmd,
    }

    dap.configurations.haskell = {
        {
            name = "Haskell debug main",
            type = "ghc",
            request = "launch",
            workspace = "${workspaceFolder}",
            startup = "${workspaceFolder}/main.hs",
            startupFunc = "", -- defaults to 'main' if not set
            startupArgs = "",
            stopOnEntry = false,
            mainArgs = "",
            logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
            logLevel = "Error", -- 'Debug' | 'Info' | 'Warning' | 'Error'
            ghciEnv = vim.empty_dict(),
            ghciPrompt = "λ: ",
            ghciInitialPrompt = "ghci> ",
            ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
            forceInspect = false,
        },
        {
            name = "Haskell debug current file",
            type = "ghc",
            request = "launch",
            workspace = "${fileDirname}",
            startup = "${file}",
            startupFunc = "", -- defaults to 'main' if not set
            startupArgs = "",
            stopOnEntry = false,
            mainArgs = "",
            logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
            logLevel = "Error", -- 'Debug' | 'Info' | 'Warning' | 'Error'
            ghciEnv = vim.empty_dict(),
            ghciPrompt = "λ: ",
            ghciInitialPrompt = "ghci> ",
            ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
            forceInspect = false,
        }
    }
end

return M