-- Python formatter configuration
local M = {}

---@class PythonFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.python").black }

return M