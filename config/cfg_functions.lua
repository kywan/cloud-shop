--- Sends a notification to a specific player on the client.
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ClientNotify(msg, type)
	lib.notify({
		title = "Shop",
		description = msg,
		type = type,
		position = "top-left",
		duration = 5000,
	})
end

--- Sends a notification to a specific player on the server.
---@param source number -- Player's source ID
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ServerNotify(source, msg, type)
	TriggerClientEvent("ox_lib:notify", source, {
		title = "Shop",
		description = msg,
		type = type,
		position = "top-left",
		duration = 5000,
	})
end

--- Toggles the HUD visibility.
--- @param state boolean Whether to enable or disable the HUD
local function ToggleHud(state)
	DisplayHud(state)
	DisplayRadar(state)
end

--- Displays a help text.
--- @param msg string The message to display
local function HelpText(msg)
	AddTextEntry("helpText", msg)
	DisplayHelpTextThisFrame("helpText", false)
end

return {
	Notify = {
		Client = ClientNotify,
		Server = ServerNotify,
	},
	Interact = {
		HelpText = HelpText,
	},
	ToggleHud = ToggleHud,
}
