local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("esx", "es_extended") then return end

local ESX = exports["es_extended"]:getSharedObject()

local inShop = {}

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return ESX.GetPlayerFromId(source)
end

local function CanCarryItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.canCarryItem(itemName, itemQuantity)
	end
end

local function AddItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.addInventoryItem(itemName, itemQuantity)
	end
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

if not Config.WeaponAsItem and not Config.OxInventory then
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
end

local function ProcessTransaction(source, type, cartArray)
	if not source or source == 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end
	if not inShop[source] then return false, "Not in shop state" end

	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false, "Player not found" end

	local accountType = type == "bank" and "bank" or "money"
	local totalCartPrice = 0

	for _, item in ipairs(cartArray) do
		local availableMoney = xPlayer.getAccount(accountType).money or 0
		local totalItemPrice = (item.price * item.quantity) or 0

		if availableMoney >= totalItemPrice then
			local isWeapon = item.name:sub(1, 7):lower() == "weapon_"
			if isWeapon and not Config.WeaponAsItem and not Config.OxInventory then
				if not HasWeapon(source, item.name) then
					xPlayer.removeAccountMoney(accountType, totalItemPrice)
					AddWeapon(source, item.name)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					Functions.Notify.Server(source, {
						title = Locales.Notify.CantCarry.Weapons.title,
						description = Locales.Notify.CantCarry.Weapons.description:format(item.label),
						type = Locales.Notify.CantCarry.Weapons.type,
					})
				end
			else
				if CanCarryItem(source, item.name, item.quantity) then
					xPlayer.removeAccountMoney(accountType, totalItemPrice)
					AddItem(source, item.name, item.quantity)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					Functions.Notify.Server(source, {
						title = Locales.Notify.CantCarry.Item.title,
						description = Locales.Notify.CantCarry.Item.description:format(item.label),
						type = Locales.Notify.CantCarry.Item.type,
					})
				end
			end
		else
			Functions.Notify.Server(source, {
				title = Locales.Notify.NoMoney.Shop.title,
				description = Locales.Notify.NoMoney.Shop.description:format(item.label),
				type = Locales.Notify.NoMoney.Shop.type,
			})
		end
	end

	if totalCartPrice > 0 then
		Functions.Notify.Server(source, {
			title = Locales.Notify.PaymentSuccess.Shop.title,
			description = Locales.Notify.PaymentSuccess.Shop.description:format(totalCartPrice),
			type = Locales.Notify.PaymentSuccess.Shop.type,
		})
		return true, ("Purchased item(s) for $%s"):format(totalCartPrice)
	end
	return false, "No items purchased"
end

lib.callback.register("cloud-shop:server:HasLicense", HasLicense)
lib.callback.register("cloud-shop:server:BuyLicense", function(source, shopData)
	local success, reason = BuyLicense(source, shopData)
	return success, reason
end)
lib.callback.register("cloud-shop:server:ProcessTransaction", function(source, type, cartArray)
	local success, reason = ProcessTransaction(source, type, cartArray)
	return success, reason
end)
lib.callback.register("cloud-shop:server:InShop", function(source, status)
	inShop[source] = status
end)
