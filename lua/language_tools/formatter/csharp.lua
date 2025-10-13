-- CSharp formatter configuration
local M = {}

-- if not installed using nix use:
-- dotnet tool install -g csharpier --version 0.30.6

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
