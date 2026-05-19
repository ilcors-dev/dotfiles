local M = {}

local function get_progress()
	local ok, progress = pcall(require, "fidget.progress")
	if ok then
		return progress
	end
end

function M.start(opts)
	local progress = get_progress()
	if not progress then
		return nil
	end

	opts = opts or {}
	return progress.handle.create({
		title = opts.title,
		message = opts.message,
	})
end

function M.update(handle, message)
	if not handle or handle.done or not message or message == "" then
		return
	end

	handle.message = message
end

function M.finish(handle, message)
	if not handle or handle.done then
		return
	end

	if message and message ~= "" then
		handle.message = message
	end

	handle:finish()
end

return M
