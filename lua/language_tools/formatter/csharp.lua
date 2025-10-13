-- CSharp formatter configuration
local M = {}

M.config = { 
    function()
        return {
            exe = "csharpier",
            args = {
                "format"
            },
            stdin = true,
        }
    end
}

return M
