-- Credits to "buddiestv." (Discord)
local function DoesExportExist(resource, export)
	local exists = false

	TriggerEvent(string.format("__cfx_export_%s_%s", resource, export), function(_)
		exists = true
	end)

	return exists
end

return DoesExportExist
