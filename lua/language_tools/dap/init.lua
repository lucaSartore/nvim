-- Main DAP configuration file
local dap = require("dap")
local M = {}
local enabled_languages = require("language_tools.enabled_languages")

-- Initialize all DAP related configurations
function M.setup()
    -- Set up DAP keybindings
    M.setup_keybindings()
    
    -- Configure DAP highlight
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    
    -- Set up individual language debugger adapters based on enabled languages
    if enabled_languages.is_language_enabled("python") then
        require("language_tools.dap.python").setup()
    end
    
    if enabled_languages.is_language_enabled("go") then
        require("language_tools.dap.go").setup()
    end
    
    if enabled_languages.is_language_enabled("rust") then
        require("language_tools.dap.rust").setup()
    end
    
    if enabled_languages.is_language_enabled("javascript") then
        require("language_tools.dap.javascript").setup()
    end
    
    if enabled_languages.is_language_enabled("haskell") then
        require("language_tools.dap.haskell").setup()
    end
    
    -- Load launch.json configurations if available
    M.setup_launch_json()
end

-- Set up DAP keybindings
function M.setup_keybindings()
    -- Brakepoints
    vim.api.nvim_set_keymap(
        "n",
        "<leader>db",
        "",
        { desc = "[D]ebug [B]reakpoint", callback = dap.toggle_breakpoint }
    )
    vim.api.nvim_set_keymap("n", "<leader>dB", "", {
        desc = "[D]ebug [B]reakpoint (with condition)",
        callback = function()
            local condition = vim.fn.input('Breakpoint condition [e.g. "x == 5"]')
            local count = vim.fn.input('Breakpoint count  [e.g. "8"]')
            local log = vim.fn.input('Breakpoint log  [e.g. "a is equal to {a}"]')
            if condition == "" then
                condition = nil
            end
            if count == "" then
                count = nil
            end
            if log == "" then
                log = nil
            end
            dap.set_breakpoint(condition, count, log)
        end,
    })

    -- motions
    vim.api.nvim_set_keymap("n", "<F5>", "", { desc = "Debug continue", callback = dap.continue })
    vim.api.nvim_set_keymap("n", "<F6>", "", { desc = "Debug run last session", callback = dap.run_last })
    vim.api.nvim_set_keymap("n", "<F9>", "", { desc = "Toggle Brakepoints", callback = dap.toggle_breakpoint })
    vim.api.nvim_set_keymap("n", "<F10>", "", { desc = "Debug step over", callback = dap.step_over })
    vim.api.nvim_set_keymap("n", "<F11>", "", { desc = "Debug step into", callback = dap.step_into })
    vim.api.nvim_set_keymap("n", "<F12>", "", { desc = "Debug step out", callback = dap.step_out })
end

-- Set up support for launch.json configurations
function M.setup_launch_json()
    local vscode = require("dap.ext.vscode")
    vscode.json_decode = require("json5").parse -- custom parser that accept comments

    if vim.fn.filereadable(".vscode/launch.json") then
        vscode.load_launchjs()
    end
end

return M