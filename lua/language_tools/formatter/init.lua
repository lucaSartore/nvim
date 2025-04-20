-- Main formatter configuration file
local M = {}

---@class FormatterConfig
---@field setup function Function to set up all formatters

function M.setup()
    require("formatter").setup({
        logging = false,
        filetype = {
            lua = require("language_tools.formatter.lua").config,
            python = require("language_tools.formatter.python").config,
            javascript = require("language_tools.formatter.javascript").config,
            typescript = require("language_tools.formatter.typescript").config,
            typescriptreact = require("language_tools.formatter.typescriptreact").config,
            go = require("language_tools.formatter.go").config,
            haskell = require("language_tools.formatter.haskell").config,
            rust = require("language_tools.formatter.rust").config
        },
    })
end

return M