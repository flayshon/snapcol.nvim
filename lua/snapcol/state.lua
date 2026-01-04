local M = {}

local state = {}

function M.get(bufnr)
	if not state[bufnr] then
		state[bufnr] = {
			enabled = false,
			last_col = 0,
		}
	end
	return state[bufnr]
end

function M.clear(bufnr)
	state[bufnr] = nil
end

return M
