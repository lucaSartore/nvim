-- Rust formatter configuration
local M = {}

---@class RustFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.rust").rustfmt }

return M
