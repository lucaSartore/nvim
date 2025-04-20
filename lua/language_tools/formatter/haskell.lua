-- Haskell formatter configuration
local M = {}

---@class HaskellFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.haskell").ormolu }

return M