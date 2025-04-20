-- TypeScript React formatter configuration
local M = {}

---@class TypeScriptReactFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.typescriptreact").biome }

return M