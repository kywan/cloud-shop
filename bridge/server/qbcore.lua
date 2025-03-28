local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("qbcore", "qb-core") or DetectFramework("qbox", "qbx_core") then return end

local QBCore = exports["qb-core"]:GetCoreObject()

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return QBCore.Functions.GetPlayer(source)
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerId(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType]
end
lib.callback.register("cloud-shop:server:HasLicense", HasLicense)

function AddLicense(source, licenseType)
	if not source or source == 0 then return end
	if not licenseType then return end

	local Player = GetPlayerId(source)
	if not Player then return end

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)
end

function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		return exports["qb-inventory"]:CanAddItem(source, itemName, itemQuantity)
	end
end

function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local isWeapon = itemName:sub(1, 7):lower() == "weapon_"
		if isWeapon then return exports["qb-inventory"]:AddItem(source, itemName, itemQuantity, false, { quality = 100 }, "cloud-shop:AddWeapon") end
		return exports["qb-inventory"]:AddItem(source, itemName, itemQuantity, false, false, "cloud-shop:AddItem")
	end
end

function HasWeapon(source, weaponName)
	-- add your logic here
end

function AddWeapon(source, weaponName)
	-- add your logic here
end

function GetMoney(source, accountType)
	local Player = GetPlayerId(source)
	if not Player then return nil end
	return Player.Functions.GetMoney(accountType) or 0
end

function RemoveMoney(source, accountType, amount)
	local Player = GetPlayerId(source)
	if not Player then return end
	Player.Functions.RemoveMoney(accountType, amount)
end
