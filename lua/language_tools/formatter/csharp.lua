-- CSharp formatter configuration
local M = {}

M.config = {
    function()
        return {
            exe = "dotnet-csharpier",
            stdin = true,
        }
    end
}

return M
