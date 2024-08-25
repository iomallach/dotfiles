local M = {}

local function get_spring_boot_runner(profiles, debug)
	local debug_param = ""
	if debug then
		debug_param = ' -Drun.jvmArguments="-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" --debug-jvm'
	end

	local profile_param = ""
	if profiles then
		profile_param = " -Dspring-boot.run.profiles=" .. profiles .. " "
	end

	return "./gradlew bootRun " .. profile_param .. debug_param
end

M.run_spring_boot = function()
	local profiles = vim.fn.input("Spring profiles: ")
	local debug = vim.fn.input("Debug (y/n): ")
	if debug == "y" then
		debug = true
	else
		debug = false
	end

	vim.cmd("term " .. get_spring_boot_runner(profiles, debug))
end

return M
