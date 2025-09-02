if not detectFramework("esx", "es_extended") then return end

-- [[ Death Handling ]]

local interaction = require("client.modules.interaction")

AddEventHandler("esx:onPlayerDeath", interaction.closeUI)
