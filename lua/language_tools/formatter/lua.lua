-- Lua formatter configuration
local M = {}

---@class LuaFormatter
---@field config function[] Array of formatter providers

M.config = { require("formatter.filetypes.lua").stylua }

return M