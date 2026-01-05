local state = require("snapcol.state")

local M = {}

local defaults = {
	filetypes = nil,
}

local opts = {}

local function is_normal_buffer(bufnr)
	return vim.bo[bufnr].buftype == ""
end

local function filetype_allowed(bufnr)
	if not opts.filetypes then
		return true
	end
	return vim.tbl_contains(opts.filetypes, vim.bo[bufnr].filetype)
end

local function should_enable(bufnr)
	return is_normal_buffer(bufnr) and filetype_allowed(bufnr)
end

local function set_cursor_col(col)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()
	local max_col = math.max(#line - 1, 0)
	vim.api.nvim_win_set_cursor(0, { row, math.min(col, max_col) })
end

local function track_horizontal(bufnr)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local buf = state.get(bufnr)

	buf.row = row
	buf.col = col
end

function M.enable(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local buf = state.get(bufnr)
	if buf.enabled then
		return
	end
	buf.enabled = true

	local function vertical(cmd)
		return function()
			local count = vim.v.count1
			vim.cmd("normal! " .. count .. cmd)

			local row = vim.api.nvim_win_get_cursor(0)[1]
			local buf = state.get(bufnr)

			if buf.row == row then
				set_cursor_col(buf.col)
			else
				set_cursor_col(0)
			end
		end
	end

	-- vertical movement
	vim.keymap.set("n", "j", vertical("j"), { buffer = bufnr, silent = true })
	vim.keymap.set("n", "k", vertical("k"), { buffer = bufnr, silent = true })

	-- gg: go to top
	vim.keymap.set("n", "gg", function()
		vim.cmd("normal! gg")

		local row = vim.api.nvim_win_get_cursor(0)[1]
		local buf = state.get(bufnr)

		if buf.row == row then
			set_cursor_col(buf.col)
		else
			set_cursor_col(0)
		end
	end, { buffer = bufnr, silent = true })

	-- G: go to bottom
	vim.keymap.set("n", "G", function()
		vim.cmd("normal! G")

		local row = vim.api.nvim_win_get_cursor(0)[1]
		local buf = state.get(bufnr)

		if buf.row == row then
			set_cursor_col(buf.col)
		else
			set_cursor_col(0)
		end
	end, { buffer = bufnr, silent = true })

	-- horizontal intent
	for _, key in ipairs({ "h", "l", "w", "b", "e", "$", "^" }) do
		vim.keymap.set("n", key, function()
			local count = vim.v.count1
			vim.cmd("normal! " .. count .. key)
			track_horizontal(bufnr)
		end, { buffer = bufnr, silent = true })
	end

	-- hard reset
	vim.keymap.set("n", "0", function()
		vim.cmd("normal! 0")
		local buf = state.get(bufnr)
		buf.row = vim.api.nvim_win_get_cursor(0)[1]
		buf.col = 0
	end, { buffer = bufnr, silent = true })
end

function M.disable(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local buf = state.get(bufnr)
	if not buf.enabled then
		return
	end
	buf.enabled = false

	pcall(vim.keymap.del, "n", "j", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "k", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "gg", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "G", { buffer = bufnr })

	for _, key in ipairs({ "h", "l", "w", "b", "e", "0", "$", "^" }) do
		pcall(vim.keymap.del, "n", key, { buffer = bufnr })
	end
end

function M.toggle()
	local bufnr = vim.api.nvim_get_current_buf()
	local buf = state.get(bufnr)

	if buf.enabled then
		M.disable(bufnr)
		vim.notify("SnapCol disabled (buffer)", vim.log.levels.INFO)
	else
		if should_enable(bufnr) then
			M.enable(bufnr)
			vim.notify("SnapCol enabled (buffer)", vim.log.levels.INFO)
		else
			vim.notify("SnapCol not enabled for this buffer", vim.log.levels.WARN)
		end
	end
end

function M.setup(user_opts)
	opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

	vim.api.nvim_create_user_command("SnapColToggle", function()
		M.toggle()
	end, {})

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		callback = function(args)
			if should_enable(args.buf) then
				M.enable(args.buf)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		callback = function(args)
			state.clear(args.buf)
		end,
	})
end

return M
