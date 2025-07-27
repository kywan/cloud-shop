-- Configuration
local Functions = require("config.cfg_functions")

-- Modules
local shopPeds = require("client.modules.shop-ped")
local checkJob = require("client.modules.job")
local checkLicense = require("client.modules.license")

---@param shopKey string
local function openShopUI(shopKey)
	Functions.toggleHud(false)

	SetNuiFocus(true, true)
	SendNUIMessage({ action = "toggleShop", showShop = true })

	while IsScreenblurFadeRunning() do
		Wait(50)
	end
	TriggerScreenblurFadeIn(200)

	LocalPlayer.state:set("currentShop", shopKey, true)

	shopPeds.applySpeech("Generic_Hi", "Speech_Params_Force")
end

---@param shopKey string
---@param shopData table
local function openShop(shopKey, shopData)
	if not shopKey or not shopData then return end

	Print.Verbose("[openShop]", json.encode({ "Categories:", shopData.Categories, "Items:", shopData.Items }))

	if shopData.Requirement.Job.Required and not checkJob(shopData) then return end
	if shopData.Requirement.License.Required and not checkLicense(shopKey, shopData) then return end

	openShopUI(shopKey)
end

local function closeShopUI()
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "toggleShop", showShop = false })

	while IsScreenblurFadeRunning() do
		Wait(50)
	end
	TriggerScreenblurFadeOut(200)

	Functions.toggleHud(true)

	LocalPlayer.state:set("currentShop", nil, true)
end

local function closeShop()
	closeShopUI()
	shopPeds.applySpeech("Generic_Bye", "Speech_Params_Force")
end

return {
	open = openShop,
	openUI = openShopUI,
	close = closeShop,
	closeUI = closeShopUI,
}
