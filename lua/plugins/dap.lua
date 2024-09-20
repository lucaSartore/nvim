--------------------------------- modification to dap behavior ------------------------------------
local DapUiLeftElements = {
	Scopes = { Regex = "DAP Scopes$", Id = "scopes", Order = 1, WindowIndex = 1 },
	Brakepoints = {
		Regex = "DAP Breakpoints$",
		Id = "breakpoints",
		Order = 2,
		WindowIndex = 2,
	},
	Stacks = {
		Regex = "DAP Stacks$",
		Id = "stacks",
		Order = 3,
		WindowIndex = 3,
	},
	Watchers = {
		Regex = "DAP Watches$",
		Id = "watches",
		Order = 4,
		WindowIndex = 4,
	},
	All = {},
}

local DapUiBottomElements = {
	Repl = {
		Regex = "%[dap%-repl%-%d%d?%d?%]$",
		Id = "repl",
		Order = 1,
		WindowIndex = 5,
	},
	Console = {
		Regex = "DAP Console$",
		Id = "console",
		Order = 2,
		WindowIndex = 6,
	},
}

-- assuming to_call create one and one only new buffer in the windows
-- this function will find which one has been created and return int
local function get_new_buffer(to_call)
	local buffers_pre = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		buffers_pre[buf] = true
	end
	to_call()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if buffers_pre[buf] ~= true then
			return buf
		end
	end
	error("no new buffer found")
end

local function get_element(elements, index)
	for _, value in pairs(elements) do
		if value.Order == index then
			return value
		end
	end
	error("unable to find element by inex")
end

local function select_window_from_buffer(buf)
	local windows = vim.api.nvim_list_wins()

	for _, win in ipairs(windows) do
		local win_buf = vim.api.nvim_win_get_buf(win)
		if win_buf == buf then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	error("unable to find buffer")
end

local increase_left, decrease_left, increase_bottom, decrease_bottom
local set_left_element_by_index, set_bottom_element_by_index

local function attach_left_window_keymap(bufer)
	vim.api.nvim_buf_set_keymap(
		bufer,
		"n",
		">",
		"",
		{ noremap = true, silent = true, callback = increase_left, desc = "next debug element" }
	)
	vim.api.nvim_buf_set_keymap(
		bufer,
		"n",
		"<",
		"",
		{ noremap = true, silent = true, callback = decrease_left, desc = "preb debug element" }
	)
	vim.api.nvim_buf_set_keymap(bufer, "n", "b", "", {
		noremap = true,
		silent = true,
		callback = function()
			set_left_element_by_index(2)
		end,
		desc = "Brakepoints",
	})
	vim.api.nvim_buf_set_keymap(bufer, "n", "s", "", {
		noremap = true,
		silent = true,
		callback = function()
			set_left_element_by_index(3)
		end,
		desc = "Stack tracke",
	})
	vim.api.nvim_buf_set_keymap(bufer, "n", "w", "", {
		noremap = true,
		silent = true,
		callback = function()
			set_left_element_by_index(4)
		end,
		desc = "Watches",
	})
	vim.api.nvim_buf_set_keymap(bufer, "n", "S", "", {
		noremap = true,
		silent = true,
		callback = function()
			set_left_element_by_index(1)
		end,
		desc = "Scopes",
	})
	select_window_from_buffer(bufer)
end

local function attach_bottom_window_keymap(buf)
	vim.api.nvim_buf_set_keymap(buf, "n", ">", "", { noremap = true, silent = true, callback = increase_bottom })
	vim.api.nvim_buf_set_keymap(buf, "n", "<", "", { noremap = true, silent = true, callback = decrease_bottom })
	select_window_from_buffer(buf)
end

local function swapp_elements(new, old)
	local dapui = require("dapui")
	dapui.close(old.WindowIndex)
	local new_buffer = get_new_buffer(function()
		dapui.open(new.WindowIndex)
	end)
	return new_buffer
end

set_left_element_by_index = function(index)
	local oldElement = vim.g.dapui_left_element
	local newElement = get_element(DapUiLeftElements, index)
	vim.g.dapui_left_element = newElement
	local buf = swapp_elements(newElement, oldElement)
	attach_left_window_keymap(buf)
end

set_bottom_element_by_index = function(index)
	local oldElement = vim.g.dapui_bottom_element
	local newElement = get_element(DapUiBottomElements, index)
	vim.g.dapui_bottom_element = newElement
	local buf = swapp_elements(newElement, oldElement)
	attach_bottom_window_keymap(buf)
end

increase_left = function()
	local index = (vim.g.dapui_left_element.Order + 1)
	if index == 5 then
		index = 1
	end
	set_left_element_by_index(index)
end

decrease_left = function()
	local index = (vim.g.dapui_left_element.Order - 1)
	if index == 0 then
		index = 4
	end
	set_left_element_by_index(index)
end

increase_bottom = function()
	local index = (vim.g.dapui_bottom_element.Order + 1)
	if index == 3 then
		index = 1
	end
	set_bottom_element_by_index(index)
end

decrease_bottom = function()
	local index = (vim.g.dapui_bottom_element.Order - 1)
	if index == 0 then
		index = 2
	end
	set_bottom_element_by_index(index)
end

local DapUiLayoutConfig = {
	{
		elements = { DapUiLeftElements.Scopes.Id },
		size = 40,
		position = "left",
	},
	{
		elements = { DapUiLeftElements.Brakepoints.Id },
		size = 40,
		position = "left",
	},
	{
		elements = { DapUiLeftElements.Stacks.Id },
		size = 40,
		position = "left",
	},
	{
		elements = { DapUiLeftElements.Watchers.Id },
		size = 40,
		position = "left",
	},
	{
		elements = { DapUiBottomElements.Repl.Id },
		size = 10,
		position = "bottom",
	},
	{
		elements = { DapUiBottomElements.Console.Id },
		size = 10,
		position = "bottom",
	},
}

vim.g.dapui_left_element = DapUiLeftElements.Watchers
vim.g.dapui_bottom_element = DapUiBottomElements.Repl
vim.g.left_dapui_visible = false
vim.g.bottom_dapui_visible = false

local function openLeftDapUI()
	if vim.g.left_dapui_visible == true then
		return
	end
	local dapui = require("dapui")
	local left = vim.g.dapui_left_element
	local buf = get_new_buffer(function()
		dapui.open(left.WindowIndex)
	end)
	attach_left_window_keymap(buf)
	vim.g.left_dapui_visible = true
end

local function closeLeftDapUi()
	local dapui = require("dapui")
	dapui.close(vim.g.dapui_left_element.WindowIndex)
	vim.g.left_dapui_visible = false
end

local function openBottomDapUI()
	if vim.g.bottom_dapui_visible == true then
		return
	end
	local dapui = require("dapui")
	local bottom = vim.g.dapui_bottom_element
	local buf = get_new_buffer(function()
		dapui.open(bottom.WindowIndex)
	end)
	attach_bottom_window_keymap(buf)
	vim.g.bottom_dapui_visible = true
end

local function closeBottomDapUi()
	local dapui = require("dapui")
	dapui.close(vim.g.dapui_bottom_element.WindowIndex)
	vim.g.bottom_dapui_visible = false
end

local function toggleLeftDapUi()
	if vim.g.left_dapui_visible then
		closeLeftDapUi()
	else
		openLeftDapUI()
	end
end

local function toggleBottomDapUi()
	if vim.g.bottom_dapui_visible then
		closeBottomDapUi()
	else
		openBottomDapUI()
	end
end

local function closeDapUi()
	closeLeftDapUi()
	closeBottomDapUi()
end

local function openDapUi()
	if vim.g.bottom_dapui_visible and vim.g.left_dapui_visible then
		closeDapUi()
		return
	end
	openLeftDapUI()
	openBottomDapUI()
end

-- ------------------------------------------ breakpoints conditions --------------------------------
--
-- ---@class ExceptionBreakpointsFilter
-- ---@field filter string
-- ---@field label string
-- ---@field description string|nil
-- ---@field default boolean|nil
-- ---@field supportsCondition boolean|nil
-- ---@field conditionDescription string|nil
--
-- local supported_filters = nil
-- local selected_filters = nil
--
-- local function set_default_filters()
-- 	selected_filters = {}
-- 	if supported_filters == nil then
-- 		return
-- 	end
-- 	for _, value in ipairs(supported_filters) do
-- 		if value.default == true then
-- 			table.insert(selected_filters, value.filter)
-- 		end
-- 	end
-- end
--
-- -- function used to check if the capabilities has changed, and in case there is a mismatched between the selected
-- -- one and the available the function automatically set the default one
-- local function check_selected_filters()
-- 	if supported_filters == nil then
-- 		return
-- 	end
-- 	if selected_filters == nil then
-- 		set_default_filters()
-- 	end
-- 	local ok = true
-- 	for _, selected in ipairs(selected_filters) do
-- 		local find_one = false
-- 		for _, supported in ipairs(supported_filters) do
-- 			if selected.filter == supported.filter then
-- 				find_one = true
-- 				break
-- 			end
-- 		end
-- 		if not find_one then
-- 			ok = false
-- 			break
-- 		end
-- 	end
--
-- 	if not ok then
-- 		set_default_filters()
-- 	end
-- end
--
-- local function myUiSetup()
-- 	local dap = require("dap")
--
-- 	dap.listeners.after.initialize.my_test = function(session, body)
-- 		supported_filters = session.capabilities.exceptionBreakpointFilters
-- 		check_selected_filters()
-- 		-- setting the capabilities
-- 		dap.set_exception_breakpoints(selected_filters)
-- 	end
-- end

-------------------------------------- Actual dap configuration -----------------------------------------------

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
		local dapui = require("dapui")
		-- myUiSetup()
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

		--------------------- FRONT END DEV  ----------------------------

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
								default = "http://localhost:3000",
							}, function(url)
								if url == nil or url == "" then
									return
								else
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

		------------------ OPEN LAUNCH.JSON CONFIGURATIONS ---------------------------

		local vscode = require("dap.ext.vscode")
		vscode.json_decode = require("json5").parse -- custom parser that accept comments

		if vim.fn.filereadable(".vscode/launch.json") then
			vscode.load_launchjs()
		end

		-------------------     UI     ------------------------------
		require("dapui").setup({
			layouts = DapUiLayoutConfig,
		})
		require("neodev").setup({
			library = { plugins = { "nvim-dap-ui" }, types = true },
		})

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

		-- debug UI
		vim.api.nvim_set_keymap(
			"n",
			"<leader>du",
			"",
			{ desc = "[D]ebug [U]ser Interface (open)", callback = openDapUi }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>dU",
			"",
			{ desc = "[D]ebug [U]ser Interface (close)", callback = closeDapUi }
		)
		vim.api.nvim_set_keymap("n", "<leader>dh", "", { desc = "[D]ebug Toggle Left UI", callback = toggleLeftDapUi })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>dj",
			"",
			{ desc = "[D]ebug Toggle Bottom UI", callback = toggleBottomDapUi }
		)
		vim.api.nvim_set_hl(0, "blue", { fg = "#56b6c2" })
		vim.api.nvim_set_hl(0, "green", { fg = "#98c379" })
		vim.api.nvim_set_hl(0, "red", { fg = "#ca1143" })
		vim.api.nvim_set_hl(0, "gray", { fg = "#cccccc" })

		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "", texthl = "red", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "", texthl = "red", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "", texthl = "gray", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
		vim.fn.sign_define(
			"DapStopped",
			{ text = "", texthl = "green", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
		vim.fn.sign_define(
			"DapLogPoint",
			{ text = "", texthl = "blue", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)

		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
	end,
}
