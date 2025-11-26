local dap = require("dap")
local M = {}

function M.setup()
	local executable = nil
	dap.configurations.cpp = {
		{
			name = "Launch",
			type = "codelldbcpp",
			request = "launch",
			program = function()
				if executable == nil then
					executable = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end
				return executable
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			runInTerminal = true,
		},
		{
			name = "Launch (uncashed input)",
			type = "codelldbcpp",
			request = "launch",
			program = function()
				executable = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				return executable
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			runInTerminal = true,
		},
	}
	require("dap").adapters.codelldbcpp = {
		type = "server",
		port = "${port}",
		executable = {
			command = "codelldb",
			args = { "--port", "${port}" },
		},
	}
end

return M
