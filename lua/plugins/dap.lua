return {
	"mfussenegger/nvim-dap",
	recommended = true,
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"jay-babu/mason-nvim-dap.nvim",
		"williamboman/mason.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"stevearc/overseer.nvim", -- make launch.json's PreLaunchTask work
		{
            -- to make json comment work. some times install.sh dose not work and need to be manually run
            "Joakker/lua-json5",

            build = function ()
                local base_path = vim.fn.stdpath("data") .. "/lazy/lua-json5"
                local cmd = base_path .. "/install." .. (vim.fn.has("win32") == 1 and "ps1" or "sh")
                vim.system({cmd}, {cwd=base_path})
            end,
        },
		"leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap-python",
		{
			"microsoft/vscode-js-debug",
			build = (function()
				if vim.g.windows then
					return "cmd.exe /c \"npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle &&  (if exist out rmdir /s /q out) && move dist out\""
				else
					return "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out"
				end
			end)(),
			version = "1.*",
		},
		"mxsdev/nvim-dap-vscode-js",
	},
	config = function()
		-- Setup overseer for task management
		require("overseer").setup()

		-- Configure the DAP virtual text display
		require("nvim-dap-virtual-text").setup({
			clear_on_continue = true, -- clear virtual text on "continue" (might cause flickering when stepping)
			display_callback = function(variable, buf, stackframe, node, options)
				-- limit the size of the displayed text
				local value = variable.value:gsub("%s+", " ")
				if #value > 35 then
					value = value:sub(0, 32) .. "..."
				end
				if options.virt_text_pos == "inline" then
					return " = " .. value
				else
					return variable.name .. " = " .. value
				end
			end,
		})

		-- Set up all DAP components from our modular structure
		require("language_tools.dap").setup()
	end,
}
