-- After extracting cargo's compiler metadata with the cargo inspector
-- parse it to find the binary to debug
local function parse_cargo_metadata(cargo_metadata)
  -- Iterate backwards through the metadata list since the binary
  -- we're interested will be near the end (usually second to last)
  for i = 1, #cargo_metadata do
    local json_table = cargo_metadata[#cargo_metadata + 1 - i]

    -- Some metadata lines may be blank, skip those
    if string.len(json_table) ~= 0 then
      -- Each matadata line is a JSON table,
      -- parse it into a data structure we can work with
      json_table = vim.fn.json_decode(json_table)

      -- Our binary will be the compiler artifact with an executable defined
      if json_table["reason"] == "compiler-artifact" and json_table["executable"] ~= vim.NIL then
        return json_table["executable"]
      end
    end
  end

  return nil
end


-- Parse the `cargo` section of a DAP configuration and add any needed
-- information to the final configuration to be handed back to the adapter.
-- E.g.: When debugging a test, cargo generates a random executable name.
-- We need to ask cargo for the name and add it to the `program` config field
-- so LLDB can find it.
local function cargo_inspector(config)
  local final_config = vim.deepcopy(config)

  -- Create a buffer to receive compiler progress messages
  local compiler_msg_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(compiler_msg_buf, "buftype", "nofile")

  -- And a floating window in the corner to display those messages
  local window_width = math.max(#final_config.name + 1, 50)
  local window_height = 12
  local compiler_msg_window = vim.api.nvim_open_win(compiler_msg_buf, false, {
    relative = "editor",
    width = window_width,
    height = window_height,
    col = vim.api.nvim_get_option "columns" - window_width - 1,
    row = vim.api.nvim_get_option "lines" - window_height - 1,
    border = "rounded",
    style = "minimal",
  })

  -- Let the user know what's going on
  vim.fn.appendbufline(compiler_msg_buf, "$", "Compiling: ")
  vim.fn.appendbufline(compiler_msg_buf, "$", final_config.name)
  vim.fn.appendbufline(compiler_msg_buf, "$", string.rep("=", window_width - 1))

  -- Instruct cargo to emit compiler metadata as JSON
  local message_format = "--message-format=json"
  if final_config.cargo.args ~= nil then
    table.insert(final_config.cargo.args, message_format)
  else
    final_config.cargo.args = { message_format }
  end

  -- Build final `cargo` command to be executed
  local cargo_cmd = { "cargo" }
  for _, value in pairs(final_config.cargo.args) do
    table.insert(cargo_cmd, value)
  end

  -- Run `cargo`, retaining buffered `stdout` for later processing,
  -- and emitting compiler messages to to a window
  local compiler_metadata = {}
  local cargo_job = vim.fn.jobstart(cargo_cmd, {
    clear_env = false,
    env = final_config.cargo.env,
    cwd = final_config.cwd,

    -- Cargo emits compiler metadata to `stdout`
    stdout_buffered = true,
    on_stdout = function(_, data) compiler_metadata = data end,

    -- Cargo emits compiler messages to `stderr`
    on_stderr = function(_, data)
      local complete_line = ""

      -- `data` might contain partial lines, glue data together until
      -- the stream indicates the line is complete with an empty string
      for _, partial_line in ipairs(data) do
        if string.len(partial_line) ~= 0 then complete_line = complete_line .. partial_line end
      end

      if vim.api.nvim_buf_is_valid(compiler_msg_buf) then
        vim.fn.appendbufline(compiler_msg_buf, "$", complete_line)
        vim.api.nvim_win_set_cursor(compiler_msg_window, { vim.api.nvim_buf_line_count(compiler_msg_buf), 1 })
        vim.cmd "redraw"
      end
    end,

    on_exit = function(_, exit_code)
      -- Cleanup the compile message window and buffer
      if vim.api.nvim_win_is_valid(compiler_msg_window) then
        vim.api.nvim_win_close(compiler_msg_window, { force = true })
      end

      if vim.api.nvim_buf_is_valid(compiler_msg_buf) then
        vim.api.nvim_buf_delete(compiler_msg_buf, { force = true })
      end

      -- If compiling succeeed, send the compile metadata off for processing
      -- and add the resulting executable name to the `program` field of the final config
      if exit_code == 0 then
        local executable_name = parse_cargo_metadata(compiler_metadata)
        if executable_name ~= nil then
          final_config.program = executable_name
        else
          vim.notify(
            "Cargo could not find an executable for debug configuration:\n\n\t" .. final_config.name,
            vim.log.levels.ERROR
          )
        end
      else
        vim.notify("Cargo failed to compile debug configuration:\n\n\t" .. final_config.name, vim.log.levels.ERROR)
      end
    end,
  })

  -- Get the rust compiler's commit hash for the source map
  local rust_hash = ""
  local rust_hash_stdout = {}
  local rust_hash_job = vim.fn.jobstart({ "rustc", "--version", "--verbose" }, {
    clear_env = false,
    stdout_buffered = true,
    on_stdout = function(_, data) rust_hash_stdout = data end,
    on_exit = function()
      for _, line in pairs(rust_hash_stdout) do
        local start, finish = string.find(line, "commit-hash: ", 1, true)

        if start ~= nil then rust_hash = string.sub(line, finish + 1) end
      end
    end,
  })

  -- Get the location of the rust toolchain's source code for the source map
  local rust_source_path = ""
  local rust_source_job = vim.fn.jobstart({ "rustc", "--print", "sysroot" }, {
    clear_env = false,
    stdout_buffered = true,
    on_stdout = function(_, data) rust_source_path = data[1] end,
  })

  -- Wait until compiling and parsing are done
  -- This blocks the UI (except for the :redraw above) and I haven't figured
  -- out how to avoid it, yet
  -- Regardless, not much point in debugging if the binary isn't ready yet
  vim.fn.jobwait { cargo_job, rust_hash_job, rust_source_job }

  -- Enable visualization of built in Rust datatypes
  final_config.sourceLanguages = { "rust" }

  -- Build sourcemap to rust's source code so we can step into stdlib
  rust_hash = "/rustc/" .. rust_hash .. "/"
  rust_source_path = rust_source_path .. "/lib/rustlib/src/rust/"
  if final_config.sourceMap == nil then final_config["sourceMap"] = {} end
  final_config.sourceMap[rust_hash] = rust_source_path

  -- Cargo section is no longer needed
  final_config.cargo = nil

  return final_config
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
		local dap = require("dap")
		require("overseer").setup()

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

		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

		local mason_registry = require("mason-registry")
		------------------------------ PYTHON ------------------------------------
		local debugpy_path = mason_registry.get_package("debugpy"):get_install_path()
		dap.adapters.debugpy = {
			type = "executable",
			command = debugpy_path .. "\\venv\\Scripts\\python",
			args = { "-m", "debugpy.adapter" },
			detached = false,
			options = {
				source_filetype = "python",
			},
		}
		dap.configurations.python = {
			{
				type = "debugpy",
				request = "launch",
				name = "Launch file",
                cwd = "${fileDirname}",
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

		dap.adapters.lldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_path,
				args = { "--port", "${port}" },
			},
            enrich_config = function(config, on_config)
                -- If the configuration(s) in `launch.json` contains a `cargo` section
                -- send the configuration off to the cargo_inspector.
                print("hello world")
                if config["cargo"] ~= nil then on_config(cargo_inspector(config)) end
            end,
		}

		dap.configurations.rust = {
			{
				name = "Rust debug",
				type = "codelldb",
				request = "launch",
				showDisassembly = "never",
				program = function()
					-- vim.fn.jobstart("cargo build")
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
			}
		end

		vim.g.default_website_launch = "http://localhost:8081"

		--------------------------------- HASKELL ---------------------------------
		local haskelldbg = mason_registry.get_package("haskell-debug-adapter")
		local haskell_cmd = haskelldbg:get_install_path() .. "/haskell-debug-adapter"

		dap.adapters.ghc = {
			type = "executable",
			command = haskell_cmd,
		}

		dap.configurations.haskell = {
			{

				name = "Haskell debug main",
				type = "ghc",
				request = "launch",
				workspace = "${workspaceFolder}",
				startup = "${workspaceFolder}/main.hs",
				startupFunc = "", -- defaults to 'main' if not set
				startupArgs = "",
				stopOnEntry = false,
				mainArgs = "",
				logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
				logLevel = "Error", -- 'Debug' | 'Info' | 'Warning' | 'Error'
				ghciEnv = vim.empty_dict(),
				ghciPrompt = "λ: ",
				ghciInitialPrompt = "ghci> ",
				ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
				forceInspect = false,
			},
            {
                name = "Haskell debug current file",
				type = "ghc",
				request = "launch",
				workspace = "${fileDirname}",
				startup = "${file}",
				startupFunc = "", -- defaults to 'main' if not set
				startupArgs = "",
				stopOnEntry = false,
				mainArgs = "",
				logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
				logLevel = "Error", -- 'Debug' | 'Info' | 'Warning' | 'Error'
				ghciEnv = vim.empty_dict(),
				ghciPrompt = "λ: ",
				ghciInitialPrompt = "ghci> ",
				ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
				forceInspect = false,
            }
		}

		------------------ OPEN LAUNCH.JSON CONFIGURATIONS ---------------------------

		local vscode = require("dap.ext.vscode")
		vscode.json_decode = require("json5").parse -- custom parser that accept comments

		if vim.fn.filereadable(".vscode/launch.json") then
			vscode.load_launchjs()
		end

		---------------------- KEYBINDINGS ---------------------------------

		-- Brakepoints
		vim.api.nvim_set_keymap(
			"n",
			"<leader>db",
			"",
			{ desc = "[D]ebug [B]reakpoint", callback = dap.toggle_breakpoint }
		)
		vim.api.nvim_set_keymap("n", "<leader>dB", "", {
			desc = "[D]ebug [B]reakpoint (with condition)",
			callback = function()
				local condition = vim.fn.input('Breakpoint condition [e.g. "x == 5"]')
				local count = vim.fn.input('Breakpoint count  [e.g. "8"]')
				local log = vim.fn.input('Breakpoint log  [e.g. "a is equal to {a}"]')
				if condition == "" then
					condition = nil
				end
				if count == "" then
					count = nil
				end
				if log == "" then
					log = nil
				end
				dap.set_breakpoint(condition, count, log)
			end,
		})

		-- motions
		vim.api.nvim_set_keymap("n", "<F5>", "", { desc = "Debug continue", callback = dap.continue })
		vim.api.nvim_set_keymap("n", "<F6>", "", { desc = "Debug run last session", callback = dap.run_last })
		vim.api.nvim_set_keymap("n", "<F9>", "", { desc = "Toggle Brakepoints", callback = dap.toggle_breakpoint })
		vim.api.nvim_set_keymap("n", "<F10>", "", { desc = "Debug step over", callback = dap.step_over })
		vim.api.nvim_set_keymap("n", "<F11>", "", { desc = "Debug step into", callback = dap.step_into })
		vim.api.nvim_set_keymap("n", "<F12>", "", { desc = "Debug step out", callback = dap.step_out })
	end,
}
