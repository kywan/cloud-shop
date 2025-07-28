---@diagnostic disable: duplicate-set-field

if not detectFramework("qbcore", "qb-core") or detectFramework("qbox", "qbx_core") then return end

local Config = require("config.main")

local QBCore = exports["qb-core"]:GetCoreObject()

Bridge = {
	License = {},
	Item = {},
	Money = {},
}

--- @param source number
--- @return table|nil
local function getPlayerObject(source)
	if not source or source == 0 then return nil end
	return QBCore.Functions.GetPlayer(source)
end

--- @param source number
--- @return string|nil, number|nil
lib.callback.register("cloud-shop:getJobData", function(source)
	local Player = getPlayerObject(source)
	if not Player then return nil end

	local job = Player.PlayerData.job or { name = "unknown", grade = { level = 0 } }
	local gang = Player.PlayerData.gang or { name = "none", label = "unknown", grade = { level = 0 } }

	-- If player has both gang and job, prioritize job info
	if gang.name ~= "none" and job.name ~= "unemployed" then return job.name, job.grade.level end

	-- Otherwise, use gang if exists, fallback to job
	return gang.name ~= "none" and gang.label or job.name, gang.name ~= "none" and gang.grade.level or job.grade.level
end)

---@param source number
---@param licenseType string
---@return boolean
lib.callback.register("cloud-shop:checkLicense", function(source, licenseType)
	if not source or source <= 0 then return false end
	if not licenseType then return false end

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType] or false
end)

---@param source number
---@param licenseType string
function Bridge.License.Add(source, licenseType)
	if not source or source <= 0 then return end
	if not licenseType then return end

	local Player = getPlayerObject(source)
	if not Player then return end

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)
end

---@param itemName string
---@return boolean
local function isWeapon(itemName)
	return itemName:sub(1, 7):lower() == "weapon_" and not Config.WeaponAsItem and GetResourceState("ox_inventory") ~= "started" and GetResourceState("qb-inventory") ~= "started"
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean
local function canCarryItem(source, itemName, quantity)
	if GetResourceState("ox_inventory") == "started" then
		return exports.ox_inventory:CanCarryItem(source, itemName, quantity)
	elseif GetResourceState("qb-inventory") == "started" then
		if not doesExportExist("qb-inventory", "CanAddItem") then
			log.warn("[Bridge.Item.CanAdd] Could not find [qb-inventory:CanAddItem] export!\nUpdate your qb-inventory version to 2.0.0 or higher to use this export")
			return true
		end
		return exports["qb-inventory"]:CanAddItem(source, itemName, quantity)
	end
	return true
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean, string|nil
local function addItem(source, itemName, quantity)
	if GetResourceState("ox_inventory") == "started" then
		local success = exports.ox_inventory:AddItem(source, itemName, quantity)
		return success and true or false, success or "Failed to add item"
	elseif GetResourceState("qb-inventory") == "started" then
		if isWeapon then return exports["qb-inventory"]:AddItem(source, itemName, quantity, false, { quality = 100 }, "cloud-shop:addWeapon") end
		return exports["qb-inventory"]:AddItem(source, itemName, quantity, false, false, "cloud-shop:addItem")
	end

	log.error("[Bridge.Item.Add] Failed to add item to inventory")
	return false
end

---@param source number
---@param weaponName string
---@return boolean
local function hasWeapon(source, weaponName)
	return false
end

---@param source number
---@param weaponName string
---@return boolean, string|nil
local function addWeapon(source, weaponName)
	return false
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean, string|nil
function Bridge.Item.Add(source, itemName, quantity)
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
function Bridge.Money.Get(source, accountType)
	if not accountType then return end

	accountType = accountType == "cash" and "money" or "bank"

	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Functions.GetMoney(accountType) or nil
end

---@param source number
---@param accountType string <"cash"|"bank">
---@param amount number
---@return boolean
function Bridge.Money.Remove(source, accountType, amount)
	if not accountType then return false end
	if not amount or amount <= 0 then return false end

	accountType = accountType == "cash" and "money" or "bank"

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Functions.RemoveMoney(accountType, amount)
end
