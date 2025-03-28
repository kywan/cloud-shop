local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("qbox", "qbx_core") then return end

local function GetPlayerObject(source)
	if not source or source == 0 then return nil end
	return exports.qbx_core:GetPlayer(source)
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerObject(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType]
end
lib.callback.register("cloud-shop:server:HasLicense", HasLicense)

function AddLicense(source, licenseType)
	if not source or source == 0 then return end
	if not licenseType then return end

	local Player = GetPlayerObject(source)
	if not Player then return end

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)
end

function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		Print.Error("[CanCarryItem] QBox framework by default only supports ox-inventory")
		return false
	end
end

function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		Print.Error("[AddItem] QBox framework by default only supports ox-inventory")
		return false
	end
end

function HasWeapon(source, weaponName)
	-- add your logic here
end

function AddWeapon(source, weaponName)
	-- add your logic here
end

function GetMoney(source, accountType)
	local Player = GetPlayerObject(source)
	if not Player then return nil end
	return Player.Functions.GetMoney(accountType) or 0
end

function RemoveMoney(source, accountType, amount)
	local Player = GetPlayerObject(source)
	if not Player then return end
	Player.Functions.RemoveMoney(accountType, amount)
end
