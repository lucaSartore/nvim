local vscode_debug_install
if vim.g.windows then
	vscode_debug_install =
		"npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle &&  (if exist out rmdir /s /q out) && move dist out"
else
	vscode_debug_install =
		"npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out"
end

local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "vue",
}


return {
	"mfussenegger/nvim-dap",
	recommended = true,
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio", "folke/neodev.nvim" } },
		"jay-babu/mason-nvim-dap.nvim",
		"williamboman/mason.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"stevearc/overseer.nvim", -- make launch.json's PreLaunchTask work
		{ "Joakker/lua-json5", run = "./install.sh" }, -- to make kson comment work. some times install.sh dose not work and need to be manually run
		"leoluz/nvim-dap-go",
		{
			"microsoft/vscode-js-debug",
			build = vscode_debug_install,

			version = "1.*",
		},
		"mxsdev/nvim-dap-vscode-js",
	},
	config = function()
		local dap = require("dap")
		require("overseer").setup()
		require("nvim-dap-virtual-text").setup()

		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

		local mason_registry = require("mason-registry")
		------------------------------ PYTHON ------------------------------------
		local debugpy_path = mason_registry.get_package("debugpy"):get_install_path()
		dap.adapters.debugpy = {
			type = "executable",
			command = debugpy_path .. "\\venv\\Scripts\\python",
			args = { "-m", "debugpy.adapter" },
			options = {
				source_filetype = "python",
			},
		}
		dap.configurations.python = {
			{
				type = "debugpy",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				pythonPath = vim.fn.exepath("python"),
			},
		}

		----------------------------- GO ------------------------------------------
		require("dap-go").setup()

		---------------------------- RUST ----------------------------------------------

		local codelldb = mason_registry.get_package("codelldb")
		local extension_path = codelldb:get_install_path() .. "/extension/"
		local codelldb_path = extension_path .. "adapter/codelldb"

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_path,
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.rust = {
			{
				name = "Rust debug",
				type = "codelldb",
				request = "launch",
				showDisassembly = "never",
				program = function()
					vim.fn.jobstart("cargo build")
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = true,
			},
		}

		--------------------   JAVASCIRPT  ----------------------------

		require("dap-vscode-js").setup({
			node_path = "node",
			debugger_path = vim.fn.stdpath("data") .. "\\lazy\\vscode-js-debug",
            adapters = {
              "chrome",
              "pwa-node",
              "pwa-chrome",
              "pwa-msedge",
              "pwa-extensionHost",
              "node-terminal",
            },
		})

		for _, language in ipairs(js_based_languages) do
			dap.configurations[language] = {
				-- Debug single nodejs files
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
				},
				-- Debug nodejs processes (make sure to add --inspect when you run the process)
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach",
					processId = require("dap.utils").pick_process,
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
				},
				-- Debug web applications (client side)
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch & Debug Chrome",
					url = function()
						local co = coroutine.running()
						return coroutine.create(function()
							vim.ui.input({
								prompt = "Enter URL: ",
								default = vim.g.default_website_launch,
							}, function(url)
								if url == nil or url == "" then
									return
								else

                                    vim.g.default_website_launch = url
									coroutine.resume(co, url)
								end
							end)
						end)
					end,
					webRoot = vim.fn.getcwd(),
					protocol = "inspector",
					sourceMaps = true,
					userDataDir = false,
				},
				-- Divider for the launch.json derived configs
				{
					name = "----- ↓ launch.json configs ↓ -----",
					type = "",
					request = "launch",
				},
			}
		end

        vim.g.default_website_launch = "http://localhost:8081"
		------------------ OPEN LAUNCH.JSON CONFIGURATIONS ---------------------------

		local vscode = require("dap.ext.vscode")
		vscode.json_decode = require("json5").parse -- custom parser that accept comments

		if vim.fn.filereadable(".vscode/launch.json") then
			vscode.load_launchjs()
		end


		---------------------- KEYBINDINGS ---------------------------------

		-- Brakepoints
		vim.api.nvim_set_keymap("n", "<F9>", "", { desc = "Toggle Brakepoints", callback = dap.toggle_breakpoint })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>db",
			"",
			{ desc = "[D]ebug [B]reakpoint", callback = dap.toggle_breakpoint }
		)
		vim.api.nvim_set_keymap("n", "<leader>dB", "", {
			desc = "[D]ebug [B]reakpoint (with condition)",
			callback = function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
		})
		vim.api.nvim_set_keymap(
			"n",
			"<leader>dc",
			"",
			{ desc = "[D]ebug [C]ondition brakepoints", callback = dap.set_exception_breakpoints }
		)

		-- motions
		vim.api.nvim_set_keymap("n", "<F5>", "", { desc = "Debug continue", callback = dap.continue })
		vim.api.nvim_set_keymap("n", "<F10>", "", { desc = "Debug continue", callback = dap.step_over })
		vim.api.nvim_set_keymap("n", "<F11>", "", { desc = "Debug continue", callback = dap.step_into })
		vim.api.nvim_set_keymap("n", "<F12>", "", { desc = "Debug continue", callback = dap.step_out })

	end,
}
