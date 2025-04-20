-- TypeScript formatter configuration
local M = {}

---@class TypeScriptFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.typescript").biome }

return M