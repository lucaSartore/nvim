-- Main formatter configuration file
local M = {}
local enabled_languages = require("language_tools.enabled_languages")

---@class FormatterConfig
---@field setup function Function to set up all formatters

function M.setup()
    local filetypes = {}

    -- Only include formatters for enabled language
    if enabled_languages.is_language_enabled("lua") then
        filetypes.lua = require("language_tools.formatter.lua").config
    end

    if enabled_languages.is_language_enabled("python") then
        filetypes.python = require("language_tools.formatter.python").config
    end

    if enabled_languages.is_language_enabled("javascript") then
        filetypes.javascript = require("language_tools.formatter.javascript").config
    end

    if enabled_languages.is_language_enabled("javascript") then
        filetypes.typescript = require("language_tools.formatter.typescript").config
    end

    if enabled_languages.is_language_enabled("javascript") then
        filetypes.typescriptreact = require("language_tools.formatter.typescriptreact").config
    end

    if enabled_languages.is_language_enabled("go") then
        filetypes.go = require("language_tools.formatter.go").config
    end

    -- if enabled_languages.is_language_enabled("haskell") then
    --     filetypes.haskell = require("language_tools.formatter.haskell").config
    -- end

    if enabled_languages.is_language_enabled("rust") then
        filetypes.rust = require("language_tools.formatter.rust").config
    end

    if enabled_languages.is_language_enabled("nix") then
        filetypes.nix = require("language_tools.formatter.nix").config
    end


    require("formatter").setup({
        logging = true,
        log_level = vim.log.levels.WARN,
        filetype = filetypes,
    })
end

return M
