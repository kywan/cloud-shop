local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

if not DetectFramework("qbox", "qbx_core") then return end

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return exports.qbx_core:GetPlayer(source)
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
	local Player = GetPlayerId(source)
	if not Player then return nil end
	return Player.Functions.GetMoney(accountType) or 0
end

lib.callback.register("cloud-shop:server:HasLicense", HasLicense)
lib.callback.register("cloud-shop:server:BuyLicense", function(source, shopData)
	local success, reason = BuyLicense(source, shopData)
	return success, reason
end)
function RemoveMoney(source, accountType, amount)
	local Player = GetPlayerId(source)
	if not Player then return end
	Player.Functions.RemoveMoney(accountType, amount)
end
