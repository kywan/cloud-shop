local Config = require("config.cfg_main")

if not DetectFramework("esx", "es_extended") then return end

local ESX = exports["es_extended"]:getSharedObject()

local function GetPlayerObject(source)
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
lib.callback.register("cloud-shop:server:HasLicense", HasLicense)

function AddLicense(source, licenseType)
	if not source or source == 0 then return end
	if not licenseType then return end

	TriggerEvent("esx_license:addLicense", source, licenseType)
end

function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerObject(source)
		if not xPlayer then return false end

		return xPlayer.canCarryItem(itemName, itemQuantity)
	end
end

function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerObject(source)
		if not xPlayer then return false end

		return xPlayer.addInventoryItem(itemName, itemQuantity)
	end
end

function HasWeapon(source, weaponName)
	local xPlayer = GetPlayerObject(source)
	if not xPlayer then return false end

	return xPlayer.hasWeapon(weaponName)
end

function AddWeapon(source, weaponName)
	local xPlayer = GetPlayerObject(source)
	if not xPlayer then return false end

	return xPlayer.addWeapon(weaponName, 120)
end

function GetMoney(source, accountType)
	accountType = accountType == "cash" and "money" or "bank"

	local Player = GetPlayerObject(source)
	if not Player then return nil end
	return xPlayer.getAccount(accountType).money or 0
end

function RemoveMoney(source, accountType, amount)
	accountType = accountType == "cash" and "money" or "bank"

	local Player = GetPlayerObject(source)
	if not Player then return end
	xPlayer.removeAccountMoney(accountType, amount)
end
