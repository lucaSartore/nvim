-- JavaScript formatter configuration
local M = {}

---@class JavaScriptFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.javascript").biome }

return M