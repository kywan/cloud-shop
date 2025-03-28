-- Configuration
local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

-- Modules
local Interaction = require("client.modules.cl_interaction")
local ShopPeds = require("client.modules.cl_shop-ped")

-- Utils
local HandleTransaction = require("client.utils.cl_transaction")
local CreateBlip = require("client.utils.cl_create-blip")

LocalPlayer.state.inShop = false
LocalPlayer.state.currentShop = nil

--[[ INITIALIZATION ]]

local function GetInteractDistance(data)
	if data.Interaction.HelpText.Enabled then
		return data.Interaction.HelpText.Distance
	elseif data.Interaction.FloatingText.Enabled then
		return data.Interaction.FloatingText.Distance
	end
	return nil
end

local function CreatePoints(location, data, coords)
	local shopPoint = lib.points.new({
		coords = coords,
		distance = data.PointRadius,
		interactDistance = GetInteractDistance(data),
		ped = nil,
	})

	function shopPoint:onEnter()
		if data.Indicator.Ped.Enabled then self.ped = ShopPeds.Spawn(data, self.coords) end
	end
	function shopPoint:onExit()
		if data.Indicator.Ped.Enabled then ShopPeds.Delete(self.ped) end
	end

	function shopPoint:nearby()
		if not LocalPlayer.state.inShop then
			if data.Indicator.Marker.Enabled then
				local markerConfig = data.Indicator.Marker
				---@diagnostic disable-next-line: missing-parameter
				DrawMarker(markerConfig.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerConfig.Size.x, markerConfig.Size.y, markerConfig.Size.z, markerConfig.Color[1], markerConfig.Color[2], markerConfig.Color[3], markerConfig.Color[4], markerConfig.BobUpAndDown, markerConfig.FaceCamera, 2, markerConfig.Rotate)
			end
		end

		if data.Interaction.HelpText.Enabled or data.Interaction.FloatingText.Enabled then
			if self.isClosest and self.currentDistance <= self.interactDistance then
				if IsPlayerDead(cache.playerId) or IsPedInAnyVehicle(cache.ped, false) then return end

				if not LocalPlayer.state.inShop then
					if data.Interaction.HelpText.Enabled then Functions.Interact.HelpText(Locales.Interaction.HelpText) end
					if data.Interaction.FloatingText.Enabled then Functions.Interact.FloatingHelpText(self.ped, self.coords, Locales.Interaction.FloatingText) end
				end

				if IsControlJustReleased(0, data.Interaction.OpenKey) then Interaction.Open(location, data) end
			end
		end
	end
end

for location, data in pairs(Config.Shops) do
	for i = 1, #data.Locations do
		local coords = data.Locations[i]

		if data.Blip.Enabled then CreateBlip(coords, data.Blip) end
		CreatePoints(location, data, coords)
		if data.Interaction.Target.Enabled then Functions.Interact.AddTarget(location, data, coords) end
	end
end

--[[ NUI CALLBACK ]]

RegisterNuiCallback("shop:fetchData", function(data, cb)
	if not type(data.label) == "string" then return end

	local locationData = Config.Shops[LocalPlayer.state.currentShop]

	local actions = {
		closeShop = function()
			local success = pcall(Interaction.Close)
			cb(success)
		end,

		selectCategory = function()
			PlaySoundFrontend(-1, "SELECT", "HUD_FREEMODE_SOUNDSET", true)
			cb(true)
		end,
		addToCart = function()
			PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
			cb(true)
		end,
		removeFromCart = function()
			PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
			cb(true)
		end,

		payCart = function()
			Print.Info("[NUI:payCart] Payment Type:", data.type, "Cart Array:", json.encode(data.cart))

			local success = HandleTransaction(data.type, data.cart)
			if success then ShopPeds.ApplySpeech("Generic_Thanks", "Speech_Params_Force_Shouted_Critical") end
			cb(success)
		end,

		getCategories = function()
			cb({ categories = locationData.Categories })
		end,
		getItems = function()
			cb({ items = locationData.Items })
		end,
		getLocales = function()
			Locales.UI.mainHeader = locationData.Locales
			cb({ imagePath = Config.ImagePath, locales = Locales.UI })
		end,
	}

	local action = actions[data.label]
	if action then action() end
end)

-- [[ CLEAN UP ]]

local function CleanUp()
	Interaction.CloseUI()
	ShopPeds.DeleteAll()
end

AddEventHandler("onResourceStop", function(resource)
	if resource ~= cache.resource then return end
	CleanUp()
end)

AddEventHandler("gameEventTriggered", function(event, data)
	if event ~= "CEventNetworkEntityDamage" then return end
	if not LocalPlayer.state.inShop then return end

	local playerId, playerDead = data[1], data[4]
	if not IsPedAPlayer(playerId) then return end

	local currentPlayer = cache.playerId
	if playerDead and NetworkGetPlayerIndexFromPed(playerId) == currentPlayer and IsPlayerDead(currentPlayer) then Interaction.CloseUI() end
end)
