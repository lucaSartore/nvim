-- CSharp formatter configuration
local M = {}

local nix_installation = vim.fn.executable("dotnet-csharpier") ~= 0
local command = nix_installation  and "dotnet-csharpier" or "csharpier"

M.config = {
    function()
        return {
            exe = command,
            stdin = true,
        }
    end
}

return M
