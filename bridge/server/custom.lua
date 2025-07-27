---@diagnostic disable: duplicate-set-field

if not detectFramework("custom", "your_framework") then return end

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
	return exports["your_framework"]:GetPlayer(source)
end

--- Returns the player's job data.
--- @param source number
--- @return string|nil -- The job name
--- @return number|nil -- The job grade
lib.callback.register("cloud-shop:getJobData", function(source)
	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Job.Name, Player.Job.Grade
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

	return Player.License.Has(licenseType)
end)

--- Adds a license to the player
---@param source number
---@param licenseType string -- The license type to check
function bridge.license.add(source, licenseType)
	if not source or source <= 0 then return end
	if not licenseType then return end

	local Player = getPlayerObject(source)
	if not Player then return false end

	Player.License.Add(licenseType)
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

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Item.CanCarry(name, quantity)
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

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Item.Add(name, quantity)
end

--- Checks if the player already has the specified weapon.
---@param source number
---@param name string -- The weapon name
---@return boolean -- Whether the weapon is already owned
function bridge.weapon.has(source, name)
	if not name then return false end

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Weapon.Has(name)
end

--- Adds a weapon to the player.
---@param source number
---@param name string -- The weapon name
---@return boolean -- Whether the weapon was added successfully
function bridge.weapon.add(source, name)
	if not name then return false end

	local Player = getPlayerObject(source)
	if not Player then return false end

	return Player.Weapon.Add(name, 120)
end

--- Gets the player's money balance for the specified account type
---@param source number
---@param accountType string <"cash"|"bank"> -- The account type to check
---@return number|nil -- The money balance
function bridge.money.get(source, accountType)
	if not accountType then return end

	accountType = accountType == "cash" and "money" or "bank"

	local Player = getPlayerObject(source)
	if not Player then return nil end

	return Player.Account.Get(accountType).money or 0
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

	return Player.Money.Remove(accountType, amount)
end
