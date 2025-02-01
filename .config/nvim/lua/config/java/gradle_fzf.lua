-- Async stuff
local Job = require("plenary.job")

local M = {}
local opts = {
	split = "vsplit",
	cmd = "./gradlew",
	prompt = "Gradle>",
}

local function parse_gradle_tasks(output)
	local tasks = {}

	for line in output:gmatch("[^\r\n]+") do
		local task = line:match("^%s*([%w%-]+)%s+%-")

		if task then
			table.insert(tasks, task)
		end
	end

	return tasks
end

local function on_stderr(_, data)
	if data then
		vim.notify(data, vim.log.levels.ERROR)
	end
end

local function async_cache_gradle_tasks()
	Job:new({
		command = opts.cmd,
		args = { "tasks", "--no-rebuild", "--console", "plain" },
		on_exit = function(j, return_val)
			local result = table.concat(j:result(), "\r\n")
			M.tasks = parse_gradle_tasks(result)
			vim.notify("Gradle: Cached tasks!")
		end,
		on_stderr = on_stderr,
	}):start()
end

local function async_spawn_gradle_daemon()
	Job:new({
		command = opts.cmd,
		args = { "--daemon" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				vim.notify("Successfully spawned gradle daemon", vim.log.levels.INFO)
				async_cache_gradle_tasks()
			end
		end,
		on_stderr = on_stderr,
	}):start()
end

local function async_prepare_gradle_daemon()
	Job:new({
		command = opts.cmd,
		args = { "--status" },
		on_exit = function(j, return_val)
			local result = table.concat(j:result(), "\n")
			if string.match(result, "No Gradle daemons are running") then
				vim.notify("Spawning gradle daemon")
				async_spawn_gradle_daemon()
			else
				vim.notify("Gradle daemon is running")
				async_cache_gradle_tasks()
			end
		end,
		on_stderr = on_stderr,
	}):start()
end

M.run_gradle_task = function(args)
	vim.cmd(opts.split .. " | term " .. opts.cmd .. " " .. args.args)
end

M.refresh_cache = function()
	async_cache_gradle_tasks()
end

M.fzf_find_gradle_tasks = function(opts)
	local path_to_gradlew = vim.fn.getcwd() .. "/gradlew"
	local is_gradlew_there = vim.fn.filereadable(path_to_gradlew)
	if is_gradlew_there == 0 then
		vim.notify("Couldn't find gradle binary", vim.log.levels.ERROR)
		return
	end
	local fzf = require("fzf-lua")
	local fzf_opts = {
		prompt = "Gradle>",
		actions = {
			["default"] = function(selected)
				M.run_gradle_task({ args = selected[1] })
			end,
		},
	}
	fzf.fzf_exec(M.tasks or {}, fzf_opts)
end

M.init = function()
	async_prepare_gradle_daemon()
end

M.setup = function(external_opts)
	opts = vim.tbl_deep_extend("force", opts, external_opts)
	async_prepare_gradle_daemon()
end

M.init()

return M
