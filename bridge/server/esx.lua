---@diagnostic disable: duplicate-set-field

if not detectFramework("esx", "es_extended") then return end

local Config = require("config.main")

Bridge = {}

local ESX = exports["es_extended"]:getSharedObject()

--- @param source number
--- @return table|nil
local function getPlayerObject(source)
	if not source or source == 0 then return nil end
	return ESX.Player and ESX.Player(source) or ESX.GetPlayerFromId(source)
end

--- @param source number
--- @return string|nil, number|nil
lib.callback.register("cloud-shop:getJobData", function(source)
	local xPlayer = getPlayerObject(source)
	if not xPlayer then return nil end

	local job = xPlayer.getJob()
	return job.itemName, job.grade
end)

---@param source number
---@param licenseType string
---@return boolean
lib.callback.register("cloud-shop:checkLicense", function(source, licenseType)
	if not source or source <= 0 then return false end
	if not licenseType then return false end

	local result = promise.new()
	TriggerEvent("esx_license:checkLicense", source, licenseType, function(hasLicense)
		result:resolve(hasLicense)
	end)

	return Citizen.Await(result) --[[ @as boolean ]]
end)

---@param source number
---@param licenseType string
function Bridge.AddLicense(source, licenseType)
	if not source or source <= 0 then return end
	if not licenseType then return end

	TriggerEvent("esx_license:addLicense", source, licenseType)
end

---@param itemName string
---@return boolean
local function isWeapon(itemName)
	return itemName:sub(1, 7):lower() == "weapon_" and not Config.WeaponAsItem and GetResourceState("ox_inventory") ~= "started"
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean
local function canCarryItem(source, itemName, quantity)
	if GetResourceState("ox_inventory") == "started" then
		return exports.ox_inventory:CanCarryItem(source, itemName, quantity)
	else
		local xPlayer = getPlayerObject(source)
		if not xPlayer then return false end

		return xPlayer.canCarryItem(itemName, quantity)
	end
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean, string|nil
local function addItem(source, itemName, quantity)
	if GetResourceState("ox_inventory") == "started" then
		local success = exports.ox_inventory:AddItem(source, itemName, quantity)
		return success and true or false, success or "Failed to add item"
	else
		local xPlayer = getPlayerObject(source)
		if not xPlayer then return false, "Player not found" end

		xPlayer.addInventoryItem(itemName, quantity)
		return true
	end
end

---@param source number
---@param weaponName string
---@return boolean
local function hasWeapon(source, weaponName)
	local xPlayer = getPlayerObject(source)
	if not xPlayer then return false end

	return xPlayer.hasWeapon(weaponName)
end

---@param source number
---@param weaponName string
---@return boolean, string|nil
local function addWeapon(source, weaponName)
	local xPlayer = getPlayerObject(source)
	if not xPlayer then return false, "Player not found" end

	xPlayer.addWeapon(weaponName, 120)
	return true
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean, string|nil
function Bridge.AddItem(source, itemName, quantity)
	if not source or source <= 0 then return false, "Invalid source" end
	if not itemName then return false, "Invalid item name" end
	if not quantity or quantity <= 0 then return false, "Invalid quantity" end

	if isWeapon(itemName) then
		if hasWeapon(source, itemName) then return false, "Already has weapon" end
		return addWeapon(source, itemName)
	else
		if not canCarryItem(source, itemName, quantity) then return false, "Cannot carry item" end
		return addItem(source, itemName, quantity)
	end
end

---@param source number
---@param accountType string <"cash"|"bank">
---@return number|nil
function Bridge.GetMoney(source, accountType)
	if not accountType then return end

	accountType = accountType == "cash" and "money" or "bank"

	local xPlayer = getPlayerObject(source)
	if not xPlayer then return nil end

	return xPlayer.getAccount(accountType).money or nil
end

---@param source number
---@param accountType string <"cash"|"bank">
---@param amount number
---@return boolean
function Bridge.RemoveMoney(source, accountType, amount)
	if not accountType then return false end
	if not amount or amount <= 0 then return false end

	accountType = accountType == "cash" and "money" or "bank"

	local xPlayer = getPlayerObject(source)
	if not xPlayer then return false end

	xPlayer.removeAccountMoney(accountType, amount)
	return true
end
