-- JavaScript/TypeScript DAP configuration
local dap = require("dap")
local M = {}

---@class JSLanguageConfig
---@field js_based_languages string[] List of languages to apply JS debug configurations to

-- List of JS-based languages that will use the same debugger
M.js_based_languages = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "vue",
}

function M.setup()
    require("dap-vscode-js").setup({
        node_path = "node",
        debugger_path = vim.fn.stdpath("data") .. "\\lazy\\vscode-js-debug",
        adapters = {
            "chrome",
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "pwa-extensionHost",
            "node-terminal",
        },
    })

    -- Set default URL for web debugging
    vim.g.default_website_launch = "http://localhost:8081"

    -- Apply configurations for all JS-based languages
    for _, language in ipairs(M.js_based_languages) do
        dap.configurations[language] = {
            -- Debug single nodejs files
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
            },
            -- Debug nodejs processes (make sure to add --inspect when you run the process)
            {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
            },
            -- Debug web applications (client side)
            {
                type = "pwa-chrome",
                request = "launch",
                name = "Launch & Debug Chrome",
                url = function()
                    local co = coroutine.running()
                    return coroutine.create(function()
                        vim.ui.input({
                            prompt = "Enter URL: ",
                            default = vim.g.default_website_launch,
                        }, function(url)
                            if url == nil or url == "" then
                                return
                            else
                                vim.g.default_website_launch = url
                                coroutine.resume(co, url)
                            end
                        end)
                    end)
                end,
                webRoot = vim.fn.getcwd(),
                protocol = "inspector",
                sourceMaps = true,
                userDataDir = false,
            },
        }
    end
end

return M