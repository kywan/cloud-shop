if not LoadResourceFile(cache.resource, "web/dist/index.html") then error("UI has not been built! Download the release version from https://github.com/cloud-resources/cloud-shop/releases") end

-- Configuration
local Config = require("config.main")
local Functions = require("config.functions")

-- Locales
local locales = lib.loadJson(("locales.%s"):format(Config.Locale))

-- Modules
local interaction = require("client.modules.interaction")
local shopPeds = require("client.modules.shop-ped")

--[[ Initialization ]]

LocalPlayer.state:set("currentShop", nil, true)

local function getInteractDistance(shopData)
	if shopData.Interaction.helpText.Enabled then
		return shopData.Interaction.helpText.Distance
	elseif shopData.Interaction.FloatingText.Enabled then
		return shopData.Interaction.FloatingText.Distance
	end
	return nil
end

local function createPoints(shopKey, shopData, shopCoords)
	local shopPoint = lib.points.new({
		coords = shopCoords,
		distance = shopData.PointRadius,
		interactDistance = getInteractDistance(shopData),
		ped = nil,
	})

	function shopPoint:onEnter()
		if shopData.Indicator.Ped.Enabled then self.ped = shopPeds.spawn(shopData, shopCoords) end
	end

	function shopPoint:onExit()
		if shopData.Indicator.Ped.Enabled then shopPeds.delete(self.ped) end
	end

	function shopPoint:nearby()
		if not LocalPlayer.state["currentShop"] then
			if shopData.Indicator.Marker.Enabled then
				local markerConfig = shopData.Indicator.Marker
				---@diagnostic disable-next-line: missing-parameter
				DrawMarker(markerConfig.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerConfig.Size.x, markerConfig.Size.y, markerConfig.Size.z, markerConfig.Color[1], markerConfig.Color[2], markerConfig.Color[3], markerConfig.Color[4], markerConfig.BobUpAndDown, markerConfig.FaceCamera, 2, markerConfig.Rotate)
			end
		end

		if shopData.Interaction.helpText.Enabled or shopData.Interaction.FloatingText.Enabled then
			if self.isClosest and self.currentDistance <= self.interactDistance then
				if IsPlayerDead(cache.playerId) or IsPedInAnyVehicle(cache.ped, false) then return end

				if not LocalPlayer.state["currentShop"] then
					if shopData.Interaction.helpText.Enabled then Functions.Interact.HelpText(locales.interaction.help_text) end
					if shopData.Interaction.FloatingText.Enabled then Functions.Interact.FloatingHelpText(locales.interaction.floating_text, self.ped, self.coords) end
				end

				if IsControlJustReleased(0, shopData.Interaction.OpenKey) then interaction.open(shopKey, shopData) end
			end
		end
	end
end

CreateThread(function()
	for shopKey, shopData in pairs(Config.Shops) do
		for i = 1, #shopData.Locations do
			local shopCoords = shopData.Locations[i]

			if shopData.Blip.Enabled then createBlip(shopCoords, shopData.Blip) end
			createPoints(shopKey, shopData, shopCoords)
			if shopData.Interaction.Target.Enabled then Functions.Interact.AddTarget(shopKey, shopData, shopCoords, interaction.open) end
		end
	end
end)

--[[ NUI Callbacks ]]

local function handleTransaction(transactionType, cartArray)
	local success, reason = lib.callback.await("cloud-shop:processTransaction", false, transactionType, cartArray)
	if reason then log.debug("[handleTransaction]", reason) end

	playSound(success and "purchase" or "error")
	return success
end

RegisterNUICallback("shop:callback", function(data, cb)
	local actionName = data.action
	if type(actionName) ~= "string" then return end

	local shopData = Config.Shops[LocalPlayer.state["currentShop"]]

	local handlers = {
		closeShop = function()
			local success = pcall(interaction.close)
			cb(success)
		end,

		payItems = function()
			log.debug(("[NUI:payItems]\nPayment Type: %s\nCart Array: %s"):format(data.type, json.encode(data.cart)))

			local success = handleTransaction(data.type, data.cart)
			if success then shopPeds.applySpeech("Generic_Thanks", "Speech_Params_Force_Shouted_Critical") end
			cb(success)
		end,

		-- Initialization

		getCategories = function()
			cb(shopData.Categories)
		end,
		getItems = function()
			cb(shopData.Items)
		end,
		getLocales = function()
			locales.ui.main.header = shopData.Locales.MainHeader
			locales.ui.cart.header = shopData.Locales.CartHeader
			cb({ imagePath = Config.ImagePath, soundVolume = (GetProfileSetting(300) / 10), locales = locales.ui })
		end,

		-- Sounds

		selectCategory = function()
			playSound("select")
			cb(true)
		end,
		addItem = function()
			playSound("add")
			cb(true)
		end,
		updateQuantity = function()
			playSound("quantity")
			cb(true)
		end,
		removeItem = function()
			playSound("remove")
			cb(true)
		end,
	}

	local handler = handlers[actionName]
	if handler then handler() end
end)

-- [[ Clean Up ]]

local function cleanUp()
	interaction.closeUI()
	shopPeds.deleteAll()
end

AddEventHandler("onResourceStop", function(resource)
	if resource ~= cache.resource then return end
	cleanUp()
end)

AddEventHandler("gameEventTriggered", function(event, data)
	if event ~= "CEventNetworkEntityDamage" then return end
	if not LocalPlayer.state["currentShop"] then return end

	local deadPed, isPedDead = data[1], data[4]
	if not IsPedAPlayer(deadPed) then return end

	local playerId = cache.playerId
	if not isPedDead or NetworkGetPlayerIndexFromPed(deadPed) ~= playerId then return end

	if IsPlayerDead(playerId) then interaction.closeUI() end
end)
