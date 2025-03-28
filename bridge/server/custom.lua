---@diagnostic disable: undefined-field

local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("custom", "your_framework") then return end

--- Retrieves the Player ID for the given source
---@param source number -- Player's source ID
---@return number -- The Player ID
local function GetPlayerObject(source)
	---@diagnostic disable-next-line: return-type-mismatch
	if not source or source == 0 then return nil end
	return Your_Framework.GetPlayer(source) -- example
end

--- Checks if the player has the specific license.
---@param source number -- Player's source ID
---@param licenseType string -- License type (e.g., "weapon")
---@return boolean -- True if the player has the license, false otherwise
local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerObject(source)
	if not Player then return false end

	return Player.HasLicense(licenseType) -- Example
end
lib.callback.register("cloud-shop:server:HasLicense", HasLicense)

--- Adds a license to the player
---@param source number -- Player's source ID
---@param licenseType string -- License type to add
function AddLicense(source, licenseType)
	if not source or source == 0 then return end
	if not licenseType then return end

	local Player = GetPlayerObject(source)
	if not Player then return end

	Player.AddLicense(licenseType)
end

--- Checks if the player can carry the specified item and quantity.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the player can carry the item, false otherwise
function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local Player = GetPlayerObject(source)
		return Player.CanCarryItem(source, itemName, itemQuantity) -- example
	end
end

--- Adds an item to the player's inventory.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the item was successfully added, false otherwise
function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local Player = GetPlayerObject(source)
		return Player.AddItem(source, itemName, itemQuantity) -- example
	end
end

--- Checks if the player already has the specified weapon.
---@param source number -- Player's source ID
---@param weaponName string -- The name of the weapon
---@return boolean -- True if the player has the weapon, false otherwise
function HasWeapon(source, weaponName)
	if not source or source == 0 then return false end
	local Player = GetPlayerObject(source)
	return Player.HasWeapon(weaponName) -- example
end

--- Adds a weapon to the player.
---@param source number -- Player's source ID
---@param weaponName string -- The name of the weapon
---@return boolean -- True if the item was successfully added, false otherwise
function AddWeapon(source, weaponName)
	if not source or source == 0 then return false end
	local Player = GetPlayerObject(source)
	return Player.AddWeapon(weaponName) -- example
end

--- Gets the player's money balance for the specified account type
---@param source number -- Player's source ID
---@param accountType string -- Account type (e.g., "cash", "bank")
---@return number|nil -- The amount of money in the specified account
function GetMoney(source, accountType)
	local Player = GetPlayerObject(source)
	if not Player then return nil end
	return Player.GetMoney(accountType) or 0 -- Example
end

--- Removes money from the player's specified account
---@param source number -- Player's source ID
---@param accountType string -- Account type (e.g., "cash", "bank")
---@param amount number -- The amount of money to remove
function RemoveMoney(source, accountType, amount)
	local Player = GetPlayerObject(source)
	if not Player then return end
	Player.RemoveMoney(accountType, amount) -- Example
end
