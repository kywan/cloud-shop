-- Configuration
local Locales = require("config.cfg_locales")

local function LicenseDialog(shopData)
	local licenseLabel = shopData.Requirement.License.Label
	local licensePrice = shopData.Requirement.License.Price

	local licenseDialog = lib.alertDialog({
		header = Locales.Dialog.License.Header:format(licenseLabel),
		content = Locales.Dialog.License.Content:format(licenseLabel, licensePrice),
		centered = true,
		cancel = true,
		size = "sm",
	})
	if licenseDialog == "confirm" then
		lib.callback.await("cloud-shop:server:InShop", false, true)

		local success, reason = lib.callback.await("cloud-shop:server:BuyLicense", false, shopData)
		Print.Debug("[LicenseDialog]", reason)

		local sound = success and "ROBBERY_MONEY_TOTAL" or "CHECKPOINT_MISSED"
		local soundSet = success and "HUD_FRONTEND_CUSTOM_SOUNDSET" or "HUD_MINI_GAME_SOUNDSET"
		PlaySoundFrontend(-1, sound, soundSet, true)

		lib.callback.await("cloud-shop:server:InShop", false, false)
	end
end

local function HandleLicense(shopData)
	if not shopData.Requirement.License.BuyDialog then
		Functions.Notify.Client({
			title = Locales.Notify.Requirement.License.title,
			description = Locales.Notify.Requirement.License.description:format(shopData.Requirement.License.Label),
			type = Locales.Notify.Requirement.License.type,
		})
		return
	end
	LicenseDialog(shopData)
end

return HandleLicense
