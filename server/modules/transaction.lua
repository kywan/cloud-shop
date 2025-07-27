-- Configuration
local Config = require("config.cfg_main")
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

---@param itemName string
---@return boolean
local function isWeapon(itemName)
	return itemName:sub(1, 7):lower() == "weapon_" and not Config.Inventory.WeaponAsItem and not GetResourceState("ox_inventory") == "started" and not GetResourceState("qb-inventory") == "started"
end

---@param source number
---@param type string
---@param cartArray table
---@return boolean, string
lib.callback.register("cloud-shop:processTransaction", function(source, type, cartArray)
	if not source or source <= 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end

	local currentShop = Player(source).state["currentShop"]
	if not currentShop or not Config.Shops[currentShop] then return false, "Invalid shop state" end

	local accountType = type == "bank" and "bank" or "cash"
	local totalCartPrice = 0

	local shopItems = Config.Shops[currentShop].Items
	if not shopItems then return false, "Invalid shop configuration" end

	local validItems = {}
	for i = 1, #shopItems do
		local item = shopItems[i]
		validItems[item.name] = item
	end

	for i = 1, #cartArray do
		local item = cartArray[i]
		if not item or not item.name or not item.price or not item.quantity then return false, "Invalid item data" end

		local configItem = validItems[item.name]
		if not configItem then return false, "Invalid item: " .. item.name end

		if item.price ~= configItem.price then return false, "Invalid price for item: " .. item.name end
		if item.quantity <= 0 or item.quantity > 999 then return false, "Invalid quantity for item: " .. item.name end

		local availableMoney = bridge.money.get(source, accountType)
		local totalItemPrice = (item.price * item.quantity) or 0

		if availableMoney <= totalItemPrice then
			Functions.notify.server(source, {
				title = Locales.notify.no_money.shop.title,
				description = Locales.notify.no_money.shop.description:format(item.label),
				type = Locales.notify.no_money.shop.type,
			})
			goto skipItem
		end

		if isWeapon(item.name) then
			if not bridge.weapon.has(source, item.name) then
				bridge.money.remove(source, accountType, totalItemPrice)
				bridge.weapon.add(source, item.name)
				totalCartPrice = totalCartPrice + totalItemPrice
			else
				Functions.notify.server(source, {
					title = Locales.notify.cant_carry.weapon.title,
					description = Locales.notify.cant_carry.weapon.description:format(item.label),
					type = Locales.notify.cant_carry.weapon.type,
				})
			end
		else
			if bridge.item.canAdd(source, item.name, item.quantity) then
				bridge.money.remove(source, accountType, totalItemPrice)
				bridge.item.add(source, item.name, item.quantity)
				totalCartPrice = totalCartPrice + totalItemPrice
			else
				Functions.notify.server(source, {
					title = Locales.notify.cant_carry.item.title,
					description = Locales.notify.cant_carry.item.description:format(item.label),
					type = Locales.notify.cant_carry.item.type,
				})
			end
		end

		::skipItem::
	end

	if totalCartPrice > 0 then
		Functions.notify.server(source, {
			title = Locales.notify.payment_success.shop.title,
			description = Locales.notify.payment_success.shop.description:format(totalCartPrice),
			type = Locales.notify.payment_success.shop.type,
		})
		return true, "Purchased item(s) for $" .. totalCartPrice
	end

	return false, "Transaction failed"
end)
