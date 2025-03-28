local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("esx", "es_extended") then return end

local ESX = exports["es_extended"]:getSharedObject()

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return ESX.GetPlayerFromId(source)
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local p = promise.new()
	TriggerEvent("esx_license:checkLicense", source, licenseType, function(hasLicense)
		p:resolve(hasLicense)
	end)

	local result = Citizen.Await(p)
	return result
end

local function BuyLicense(source, shopData)
	if not source or source == 0 then return false, "Invalid source" end
	if not shopData or next(shopData) == nil then return false, "Invalid or empty shop data" end
	if not inShop[source] then return false, "Not in shop state" end

	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false, "Player not found" end

	local licenseType = shopData.License.Type
	local licenseTypeLabel = shopData.License.TypeLabel
	local amount = shopData.License.Price

	local moneyAvailable = xPlayer.getAccount("money").money
	local bankAvailable = xPlayer.getAccount("bank").money

	local accountType
	if moneyAvailable >= amount then
		accountType = "money"
	elseif bankAvailable >= amount then
		accountType = "bank"
	else
		Functions.Notify.Server(source, {
			title = Locales.Notify.NoMoney.License.title,
			description = Locales.Notify.NoMoney.License.description:format(licenseTypeLabel),
			type = Locales.Notify.NoMoney.License.type,
		})
		return false, "No money"
	end

	xPlayer.removeAccountMoney(accountType, amount)
	TriggerEvent("esx_license:addLicense", source, licenseType)

	Functions.Notify.Server(source, {
		title = Locales.Notify.PaymentSuccess.License.title,
		description = Locales.Notify.PaymentSuccess.License.description:format(licenseTypeLabel, amount),
		type = Locales.Notify.PaymentSuccess.License.type,
	})
	return true, "Successfully bought license"
end

function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.canCarryItem(itemName, itemQuantity)
	end
end

function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.addInventoryItem(itemName, itemQuantity)
	end
end

function HasWeapon(source, weaponName)
	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false end

	return xPlayer.hasWeapon(weaponName)
end

function AddWeapon(source, weaponName)
	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false end

	return xPlayer.addWeapon(weaponName, 120)
end

function GetMoney(source, accountType)
	accountType = accountType == "cash" and "money" or "bank"

	local Player = GetPlayerId(source)
	if not Player then return nil end
	return xPlayer.getAccount(accountType).money or 0
end

function RemoveMoney(source, accountType, amount)
	accountType = accountType == "cash" and "money" or "bank"

	local Player = GetPlayerId(source)
	if not Player then return end
	xPlayer.removeAccountMoney(accountType, amount)
end

lib.callback.register("cloud-shop:server:HasLicense", HasLicense)
lib.callback.register("cloud-shop:server:BuyLicense", function(source, shopData)
	local success, reason = BuyLicense(source, shopData)
	return success, reason
end)
