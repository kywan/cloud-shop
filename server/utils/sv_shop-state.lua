inShop = {}

lib.callback.register("cloud-shop:server:InShop", function(source, status, shopKey)
	if status then
		inShop[source] = shopKey
	else
		inShop[source] = nil
	end
end)
