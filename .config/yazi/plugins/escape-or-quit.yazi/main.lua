--- @sync entry

-- The `escape` action doesn't report whether it cancelled anything, so check the same states it handles.
return {
	entry = function()
		local tab = cx.active
		if tab.finder or tab.mode.is_visual or tab.current.files.filter or #tab.selected > 0 or tab.current.cwd.is_search then
			ya.emit("escape", {})
		else
			ya.emit("quit", {})
		end
	end,
}
