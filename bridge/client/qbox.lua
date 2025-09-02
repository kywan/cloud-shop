if not detectFramework("qbox", "qbx_core") then return end

-- [[ Death Handling ]]

local interaction = require("client.modules.interaction")

RegisterNetEvent("qbx_core:client:onSetMetaData", function(key, oldValue, newValue)
	if key == "isdead" and newValue then
		interaction.closeUI()
	elseif key == "inlaststand" and newValue then
		interaction.closeUI()
	end
end)
