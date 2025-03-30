-- Configuration
local Functions = require("config.cfg_functions")

-- Modules
local ShopPeds = require("client.modules.cl_shop-ped")
local HandleLicense = require("client.modules.cl_license")
local CheckJobRequirements = require("client.modules.cl_job")

local function OpenShopUI()
	Functions.ToggleHud(false)

	SetNuiFocus(true, true)
	SendNUIMessage({ action = "toggleShop", showShop = true })
	TriggerScreenblurFadeIn(200)

	LocalPlayer.state.inShop = true
	lib.callback.await("cloud-shop:server:InShop", false, true)

	ShopPeds.ApplySpeech("Generic_Hi", "Speech_Params_Force")
end
local function OpenShop(shopKey, shopData)
	if not shopKey or not shopData then return end
	LocalPlayer.state.currentShop = shopKey

	Print.Verbose("[OpenShop]", json.encode({ "Categories:", shopData.Categories, "Items:", shopData.Items }))

	if shopData.Requirement.License.Required then
		local hasLicense = lib.callback.await("cloud-shop:server:HasLicense", false, shopData.Requirement.License.Type)
		if not hasLicense then
			HandleLicense(shopData)
			return
		end
	end
	if shopData.Requirement.Job.Required and not CheckJobRequirements(shopData) then return end
	OpenShopUI()
end

local function CloseShopUI()
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "toggleShop", showShop = false })
	TriggerScreenblurFadeOut(200)

	Functions.ToggleHud(true)

	LocalPlayer.state.inShop = false
	lib.callback.await("cloud-shop:server:InShop", false, false)
end
local function CloseShop()
	LocalPlayer.state.currentShop = nil
	CloseShopUI()
	ShopPeds.ApplySpeech("Generic_Bye", "Speech_Params_Force")
end

return {
	Open = OpenShop,
	OpenUI = OpenShopUI,
	Close = CloseShop,
	CloseUI = CloseShopUI,
}
