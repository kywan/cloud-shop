-- Configuration
local Config = require("config.main")
local Functions = require("config.functions")

-- Locales
local locales = lib.loadJson(("locales.%s"):format(Config.Locale))

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

		if item.quantity <= 0 or item.quantity > 999 then return false, "Invalid quantity for item: " .. item.name end

		if item.price ~= configItem.price then return false, "Invalid price for item: " .. item.name end

		local availableMoney = Bridge.GetMoney(source, accountType)
		local totalItemPrice = item.price * item.quantity

		if availableMoney >= totalItemPrice then
			local success, message = Bridge.AddItem(source, item.name, item.quantity)
			if not success then
				Functions.Notify.Server(source, {
					title = locales.notify.cant_carry.item.title,
					description = locales.notify.cant_carry.item.description:format(item.label or item.name),
					type = locales.notify.cant_carry.item.type,
				})
				break
			end
			totalCartPrice = totalCartPrice + (item.price * item.quantity)
		else
			Functions.Notify.Server(source, {
				title = locales.notify.no_money.shop.title,
				description = locales.notify.no_money.shop.description:format(item.label),
				type = locales.notify.no_money.shop.type,
			})
		end
	end

	if totalCartPrice <= 0 then return false, "Total cart price is zero" end

	local success = Bridge.RemoveMoney(source, accountType, totalCartPrice)
	if not success then return false, "Failed to remove money from player" end

	Functions.Notify.Server(source, {
		title = locales.notify.payment_success.shop.title,
		description = locales.notify.payment_success.shop.description:format(totalCartPrice),
		type = locales.notify.payment_success.shop.type,
	})
	return true, "Purchased item(s) for $" .. totalCartPrice
end)
