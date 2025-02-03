return {
	"mfussenegger/nvim-lint",
	event = { "BufEnter", "InsertLeave", "TextChanged" },
	config = function()
		local lint = require("lint")
		local mypy = lint.linters.mypy
		local ruff = lint.linters.ruff
		local checkstyle = lint.linters.checkstyle
		local cwd = vim.fn.getcwd()

		-- If available in venv, use from venv
		local mypy_exists_in_venv = vim.fn.filereadable(cwd .. "/.venv/bin/mypy") == 1
		if mypy_exists_in_venv then
			mypy.cmd = cwd .. "/.venv/bin/mypy"
		end

		local ruff_exists_in_venv = vim.fn.filereadable(cwd .. "/.venv/bin/ruff") == 1
		if ruff_exists_in_venv then
			ruff.cmd = cwd .. "/.venv/bin/ruff"
		end

		local checkstyleCfg_exists_in_path = vim.fn.filereadable(cwd .. "/gradle/checkstyle.xml") == 1
		local path_to_checkstyle_jar =
			vim.fn.glob(require("mason-registry").get_package("checkstyle"):get_install_path() .. "/**/*.jar")
		local custom_checkstyle = {
			cmd = "java",
			args = {
				"-Dconfig_loc=" .. cwd .. "/gradle",
				"-classpath",
				path_to_checkstyle_jar .. ":" .. vim.fn.expand("~") .. "/jars/checkstyle-gyg-1.1.1.jar",
				"com.puppycrawl.tools.checkstyle.Main",
				"-c",
				cwd .. "/gradle/checkstyle.xml",
			},
			ignore_exitcode = true,
			parser = checkstyle.parser,
		}

		local java_checkstyle = nil
		if checkstyleCfg_exists_in_path then
			java_checkstyle = { "custom_checkstyle" }
		else
			java_checkstyle = { "checkstyle" }
		end
		lint.linters_by_ft = {
			c = { "clangtidy" },
			python = { "mypy", "ruff" },
			dockerfile = { "hadolint" },
			go = { "golangcilint" },
			java = java_checkstyle,
		}
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "BufWritePre" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
