local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

local debug_param = ' -Drun.jvmArguments="-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" --debug-jvm'

local function get_spring_boot_runner(profiles, debug)
	local debug_param_str = ""
	if debug then
		debug_param_str = debug_param
	end

	local profile_param = ""
	if profiles then
		profile_param = " -Dspring-boot.run.profiles=" .. profiles .. " "
	end

	return "./gradlew bootRun " .. profile_param .. debug_param_str
end

local function get_test_runner(debug, test_name, project_root)
	local debug_param_str = ""
	if debug then
		debug_param_str = debug_param
	end

	return "./gradlew --project-dir " .. project_root .. " test --tests " .. test_name .. debug_param_str .. " --info"
end

local function find_node_by_type(expr, type_name)
	while expr do
		if expr:type() == type_name then
			break
		end
		expr = expr:parent()
	end
	return expr
end

local function find_child_by_type(expr, type_name)
	local id = 0
	local expr_child = expr:child(id)
	while expr_child do
		if expr_child:type() == type_name then
			break
		end
		id = id + 1
		expr_child = expr:child(id)
	end

	return expr_child
end

-- Get Current Method Name
local function get_current_method_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local expr = find_node_by_type(current_node, "method_declaration")
	if not expr then
		return nil
	end

	local child = find_child_by_type(expr, "identifier")
	if not child then
		return nil
	end
	return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Class Name
local function get_current_class_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local class_declaration = find_node_by_type(current_node, "class_declaration")
	if not class_declaration then
		return nil
	end

	local child = find_child_by_type(class_declaration, "identifier")
	if not child then
		return nil
	end
	return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Package Name
local function get_current_package_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local program_expr = find_node_by_type(current_node, "program")
	if not program_expr then
		return nil
	end
	local package_expr = find_child_by_type(program_expr, "package_declaration")
	if not package_expr then
		return nil
	end

	local child = find_child_by_type(package_expr, "scoped_identifier")
	if not child then
		return nil
	end
	return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Full Class Name
local function get_current_full_class_name()
	local package = get_current_package_name()
	local class = get_current_class_name()
	return package .. "." .. class
end

-- Get Current Full Method Name with delimiter or default '.'
local function get_current_full_method_name(delimiter)
	delimiter = delimiter or "."
	local full_class_name = get_current_full_class_name()
	local method_name = get_current_method_name()
	return full_class_name .. delimiter .. method_name
end

local function find_gradle_project_dir()
	-- Get the absolute path of the directory where the current buffer is located
	local dir = vim.fn.expand("%:p:h")
	-- If any folder in the path has build.gradle or settings.gradle, return it
	while dir and dir ~= "" do
		local build_gradle = dir .. "/build.gradle"
		local settings_gradle = dir .. "/settings.gradle"
		if vim.fn.filereadable(build_gradle) == 1 or vim.fn.filereadable(settings_gradle) == 1 then
			return dir
		end
		-- Move one directory up
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			-- At root directory
			break
		end
		dir = parent
	end
	-- Not found
	return nil
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

M.run_test_class = function(debug)
	return function()
		local test_class = get_current_full_class_name()
		local project_root = find_gradle_project_dir()
		vim.cmd("vsplit | term " .. get_test_runner(debug, test_class, project_root))
	end
end

M.run_test_method = function(debug)
	return function()
		local test_method = get_current_full_method_name(".")
		local project_root = find_gradle_project_dir()
		vim.cmd("vsplit | term " .. get_test_runner(debug, test_method, project_root))
	end
end

return M
