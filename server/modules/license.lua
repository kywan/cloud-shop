-- Configuration
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

---@param source number
---@param shopData table
---@return boolean, string
lib.callback.register("cloud-shop:buyLicense", function(source, shopData)
	if not source or source <= 0 then return false, "Invalid source" end
	if not shopData then return false, "Invalid shop data" end
	if not Player(source).state["currentShop"] then return false, "Invalid shop state" end

	local licenseType = shopData.Requirement.License.Type
	local licenseLabel = shopData.Requirement.License.Label
	local licensePrice = shopData.Requirement.License.Price

	local cashAvailable = bridge.money.get(source, "cash")
	local bankAvailable = bridge.money.get(source, "bank")
	local accountType = nil

	if cashAvailable >= licensePrice then
		accountType = "cash"
	elseif bankAvailable >= licensePrice then
		accountType = "bank"
	else
		Functions.notify.server(source, {
			title = Locales.notify.no_money.license.title,
			description = Locales.notify.no_money.license.description:format(licenseLabel),
			type = Locales.notify.no_money.license.type,
		})
		return false, "No money"
	end

	bridge.money.remove(source, accountType, licensePrice)
	bridge.license.add(source, licenseType)

	Functions.notify.server(source, {
		title = Locales.notify.payment_success.license.title,
		description = Locales.notify.payment_success.license.description:format(licenseLabel, licensePrice),
		type = Locales.notify.payment_success.license.type,
	})
	return true, "Successfully bought license"
end)
