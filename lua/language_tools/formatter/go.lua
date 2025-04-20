-- Go formatter configuration
local M = {}

---@class GoFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.go").gofumpt }

return M