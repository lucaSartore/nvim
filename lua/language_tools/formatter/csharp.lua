-- CSharp formatter configuration
local M = {}

-- if not installed using nix use:
-- dotnet tool install -g csharpier

M.config = {
	function()
		return {
			exe = "csharpier",
			args = {
				"format",
			},
			stdin = true,
		}
	end,
}

return M
