---@diagnostic disable: duplicate-set-field

if not detectFramework("qbcore", "qb-core") or detectFramework("qbox", "qbx_core") then return end

local QBCore = exports["qb-core"]:GetCoreObject()

bridge = {
	license = {},
	weapon = {},
	item = {},
	money = {},
}

--- Returns the player object from the given source.
--- @param source number
--- @return table|nil -- The player object
local function getPlayerObject(source)
	if not source or source == 0 then return nil end
	return QBCore.Functions.GetPlayer(source)
end

--- Returns the player's job data.
--- @param source number
--- @return string|nil -- The job name
--- @return number|nil -- The job grade
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

--- Checks if the player has the specific license.
---@param source number
---@param licenseType string -- The license type to check
---@return boolean -- Whether the player has the license
lib.callback.register("cloud-shop:checkLicense", function(source, licenseType)
	if not source or source <= 0 then return false end
	if not licenseType then return false end

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType]
end)

--- Adds a license to the player
---@param source number
---@param licenseType string -- The license type to check
function bridge.license.add(source, licenseType)
	if not source or source <= 0 then return end
	if not licenseType then return end

	local Player = getPlayerObject(source)
	if not Player then return end

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)
end

--- Checks if the player can carry the specified item and quantity.
---@param source number
---@param name string -- The item name
---@param quantity number -- The quantity to check
---@return boolean -- Whether the player can carry the item
function bridge.item.canAdd(source, name, quantity)
	if not source or source <= 0 then return false end
	if not name then return false end
	if not quantity or quantity <= 0 then return false end

	if GetResourceState("ox_inventory") == "started" then
		return exports.ox_inventory:CanCarryItem(source, name, quantity)
	else
		if not doesExportExist("qb-inventory", "CanAddItem") then
			Print.Warn("[bridge.item.canAdd] Could not find [qb-inventory:CanAddItem] export!\nUpdate your qb-inventory version to 2.0.0 or higher to use this export")
			return true
		end
		return exports["qb-inventory"]:CanAddItem(source, name, quantity)
	end
end

--- Adds an item to the player's inventory.
---@param source number
---@param name string -- The item name
---@param quantity number -- The quantity to add
---@return boolean -- Whether the item was added successfully
function bridge.item.add(source, name, quantity)
	if not source or source <= 0 then return false end
	if not name then return false end
	if not quantity or quantity <= 0 then return false end

	if GetResourceState("ox_inventory") == "started" then
		return exports.ox_inventory:AddItem(source, name, quantity)
	else
		local isWeapon = name:sub(1, 7):lower() == "weapon_"
		if isWeapon then return exports["qb-inventory"]:AddItem(source, name, quantity, false, { quality = 100 }, "cloud-shop:addWeapon") end
		return exports["qb-inventory"]:AddItem(source, name, quantity, false, false, "cloud-shop:addItem")
	end
end

--- Checks if the player already has the specified weapon.
---@param source number
---@param name string -- The weapon name
---@return boolean -- Whether the weapon is already owned
function bridge.weapon.has(source, name)
	return false
end

--- Adds a weapon to the player.
---@param source number
---@param name string -- The weapon name
---@return boolean -- Whether the weapon was added successfully
function bridge.weapon.add(source, name)
	return false
end

--- Gets the player's money balance for the specified account type
---@param source number
---@param accountType string <"cash"|"bank"> -- The account type to check
---@return number|nil -- The money balance
function bridge.money.get(source, accountType)
	if not accountType then return end

	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Functions.GetMoney(accountType) or 0
end

--- Removes money from the player's specified account
---@param source number
---@param accountType string <"cash"|"bank"> -- The account type to check
---@param amount number -- The amount to remove
function bridge.money.remove(source, accountType, amount)
	if not accountType then return end
	if not amount or amount <= 0 then return end

	accountType = accountType == "cash" and "money" or "bank"

	local Player = getPlayerObject(source)
	if not Player then return end

	return Player.Functions.RemoveMoney(accountType, amount)
end
