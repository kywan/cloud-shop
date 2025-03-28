-- Configuration
local Locales = require("config.cfg_locales")

local function LicenseDialog(data)
	local licenseDialog = lib.alertDialog({
		header = Locales.Dialog.License.Header:format(data.License.TypeLabel),
		content = Locales.Dialog.License.Content:format(data.License.TypeLabel, data.License.Price),
		centered = true,
		cancel = true,
		size = "sm",
	})
	if licenseDialog == "confirm" then
		lib.callback.await("cloud-shop:server:InShop", false, true)

		local success, reason = lib.callback.await("cloud-shop:server:BuyLicense", false, data)
		Print.Debug("[LicenseDialog]", reason)

		local sound = success and "ROBBERY_MONEY_TOTAL" or "CHECKPOINT_MISSED"
		local soundSet = success and "HUD_FRONTEND_CUSTOM_SOUNDSET" or "HUD_MINI_GAME_SOUNDSET"
		PlaySoundFrontend(-1, sound, soundSet, true)

		lib.callback.await("cloud-shop:server:InShop", false, false)
	end
end

local function HandleLicense(data)
	if not data.License.BuyDialog then
		Functions.Notify.Client({
			title = Locales.Notify.Require.License.title,
			description = Locales.Notify.Require.License.description:format(data.License.TypeLabel),
			type = Locales.Notify.Require.License.type,
		})
		return
	end
	LicenseDialog(data)
end

return HandleLicense
