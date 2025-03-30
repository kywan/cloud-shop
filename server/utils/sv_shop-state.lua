inShop = {}

lib.callback.register("cloud-shop:server:InShop", function(source, status)
	inShop[source] = status
end)
