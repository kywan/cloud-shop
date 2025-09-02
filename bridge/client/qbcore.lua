if not detectFramework("qbcore", "qb-core") or detectFramework("qbox", "qbx_core") then return end

-- [[ Death Handling ]]

local interaction = require("client.modules.interaction")

RegisterNetEvent("QBCore:Player:SetPlayerData", function(value)
	if value.metadata.isdead or value.metadata.inlaststand then interaction.closeUI() end
end)
