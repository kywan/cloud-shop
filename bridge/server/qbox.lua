local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("qbox", "qbx_core") then return end

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return exports.qbx_core:GetPlayer(source)
end

local function CanCarryItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		Print.Error("QBox framework by default only supports ox-inventory")
		return false
	end
end

local function AddItem(source, itemName, itemQuantity)
	if Config.Inventory.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		Print.Error("QBox framework by default only supports ox-inventory")
		return false
	end
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerId(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType]
end

local function BuyLicense(source, shopData)
	if not source or source == 0 then return false, "Invalid source" end
	if not shopData or next(shopData) == nil then return false, "Invalid or empty shop data" end
	if not inShop[source] then return false, "Not in shop state" end

	local Player = GetPlayerId(source)
	if not Player then return false, "Player not found" end

	local licenseType = shopData.License.Type
	local licenseTypeLabel = shopData.License.TypeLabel
	local amount = shopData.License.Price

	local moneyAvailable = Player.Functions.GetMoney("cash")
	local bankAvailable = Player.Functions.GetMoney("bank")

	local accountType
	if moneyAvailable >= amount then
		accountType = "cash"
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

	Player.Functions.RemoveMoney(accountType, amount)

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)

	Functions.Notify.Server(source, {
		title = Locales.Notify.PaymentSuccess.License.title,
		description = Locales.Notify.PaymentSuccess.License.description:format(licenseTypeLabel, amount),
		type = Locales.Notify.PaymentSuccess.License.type,
	})
	return true, "Successfully bought license"
end

if not Config.Inventory.WeaponAsItem and not Config.Inventory.OxInventory then
	function HasWeapon(source, weaponName)
		-- add your logic here
	end

	function AddWeapon(source, weaponName)
		-- add your logic here
	end
end

local function ProcessTransaction(source, type, cartArray)
	if not source or source == 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end
	if not inShop[source] then return false, "Not in shop state" end

	local Player = GetPlayerId(source)
	if not Player then return false, "Player not found" end

	local accountType = type == "bank" and "bank" or "cash"
	local totalCartPrice = 0

	for _, item in ipairs(cartArray) do
		local availableMoney = Player.Functions.GetMoney(accountType) or 0
		local totalItemPrice = (item.price * item.quantity) or 0

		if availableMoney >= totalItemPrice then
			local isWeapon = item.name:sub(1, 7):lower() == "weapon_"
			if isWeapon and not Config.Inventory.WeaponAsItem and not Config.Inventory.OxInventory then
				if not HasWeapon(source, item.name) then
					Player.Functions.RemoveMoney(accountType, totalItemPrice)
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
					Player.Functions.RemoveMoney(accountType, totalItemPrice)
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
