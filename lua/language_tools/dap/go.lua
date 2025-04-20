-- Go DAP configuration
local M = {}

function M.setup()
    -- Use the dap-go plugin for Go debugging
    require("dap-go").setup()
end

return M