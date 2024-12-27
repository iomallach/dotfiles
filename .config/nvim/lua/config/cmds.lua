vim.api.nvim_create_user_command("Redir", function(ctx)
	local lines = vim.split(vim.api.nvim_exec(ctx.args, true), "\n", { plain = true })
	vim.cmd("new")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.opt_local.modified = false
end, { nargs = "+", complete = "command" })

vim.api.nvim_create_user_command("Gr", require("config.gradle_cmd").run_gradle_task, { nargs = 1 })
vim.api.nvim_create_user_command("GradleList", require("config.gradle_cmd").telescope_find_gradle_tasks, {})
