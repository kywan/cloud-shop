-- Configuration
local Locales = require("config.cfg_locales")

---@param shopKey string
---@param shopData table
local function licenseDialog(shopKey, shopData)
	local licenseLabel = shopData.Requirement.License.Label
	local licensePrice = shopData.Requirement.License.Price

	LocalPlayer.state:set("currentShop", shopKey, true)

	local dialog = lib.alertDialog({
		header = Locales.dialog.license.header:format(licenseLabel),
		content = Locales.dialog.license.content:format(licenseLabel, licensePrice),
		centered = true,
		cancel = true,
		size = "sm",
	})
	if dialog == "confirm" then
		local success, reason = lib.callback.await("cloud-shop:buyLicense", false, shopData)
		Print.Debug("[licenseDialog]", reason)

		playSound(success and "purchase" or "error")
		LocalPlayer.state:set("currentShop", nil, true)
	end
end

---@param shopKey string
---@param shopData table
local function handleLicense(shopKey, shopData)
	if not shopData.Requirement.License.BuyDialog then
		Functions.notify.client({
			title = Locales.notify.requirement.license.title,
			description = Locales.notify.requirement.license.description:format(shopData.Requirement.License.Label),
			type = Locales.notify.requirement.license.type,
		})
		return
	end
	licenseDialog(shopKey, shopData)
end

---@param shopKey string
---@param shopData table
---@return boolean
local function checkLicense(shopKey, shopData)
	local checkLicense = lib.callback.await("cloud-shop:checkLicense", false, shopData.Requirement.License.Type)
	if not checkLicense then
		handleLicense(shopKey, shopData)
		return false
	end
	return true
end

return checkLicense
