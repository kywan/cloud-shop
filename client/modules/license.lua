-- Configuration
local Config = require("config.main")

-- Locales
local locales = lib.loadJson(("locales.%s"):format(Config.Locale))

---@param shopKey string
---@param shopData table
local function licenseDialog(shopKey, shopData)
	local licenseLabel = shopData.Requirement.License.Label
	local licensePrice = shopData.Requirement.License.Price

	LocalPlayer.state:set("currentShop", shopKey, true)

	local dialog = lib.alertDialog({
		header = locales.dialog.license.header:format(licenseLabel),
		content = locales.dialog.license.content:format(licenseLabel, licensePrice),
		centered = true,
		cancel = true,
		size = "sm",
	})
	if dialog == "confirm" then
		local success, reason = lib.callback.await("cloud-shop:buyLicense", false, shopData)
		log.debug("[licenseDialog]", reason)

		playSound(success and "purchase" or "error")
		LocalPlayer.state:set("currentShop", nil, true)
	end
end

---@param shopKey string
---@param shopData table
local function handleLicense(shopKey, shopData)
	if not shopData.Requirement.License.BuyDialog then
		Functions.Notify.Client({
			title = locales.notify.requirement.license.title,
			description = locales.notify.requirement.license.description:format(shopData.Requirement.License.Label),
			type = locales.notify.requirement.license.type,
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
