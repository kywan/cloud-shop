---@diagnostic disable: duplicate-set-field

if not detectFramework("custom", "your_framework") then return end

local Config = require("config.main")

Bridge = {}

--- @param source number
--- @return table|nil
local function getPlayerObject(source)
	if not source or source == 0 then return nil end
	return exports["your_framework"]:GetPlayer(source)
end

--- @param source number
--- @return string|nil, number|nil
lib.callback.register("cloud-shop:getJobData", function(source)
	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Job.name, Player.Job.grade
end)

---@param source number
---@param licenseType string
---@return boolean
lib.callback.register("cloud-shop:checkLicense", function(source, licenseType)
	if not source or source <= 0 then return false end
	if not licenseType then return false end

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.License.Has(licenseType)
end)

---@param source number
---@param licenseType string
function Bridge.AddLicense(source, licenseType)
	if not source or source <= 0 then return end
	if not licenseType then return end

	local Player = getPlayerObject(source)
	if not Player then return false end

	Player.License.Add(licenseType)
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
	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Item.CanCarry(itemName, quantity)
end

---@param source number
---@param itemName string
---@param quantity number
---@return boolean, string|nil
local function addItem(source, itemName, quantity)
	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Item.Add(itemName, quantity)
end

---@param source number
---@param weaponName string
---@return boolean
local function hasWeapon(source, weaponName)
	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Weapon.Has(weaponName)
end

---@param source number
---@param weaponName string
---@return boolean, string|nil
local function addWeapon(source, weaponName)
	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Weapon.Add(weaponName, 120)
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

	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Account.Get(accountType).money or nil
end

---@param source number
---@param accountType string <"cash"|"bank">
---@param amount number
---@return boolean
function Bridge.RemoveMoney(source, accountType, amount)
	if not accountType then return false end
	if not amount or amount <= 0 then return false end

	accountType = accountType == "cash" and "money" or "bank"

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Money.Remove(accountType, amount)
end
