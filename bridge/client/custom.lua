if not detectFramework("custom", "your_framework") then return end

-- [[ Death Handling ]]

local interaction = require("client.modules.interaction")

AddEventHandler("baseevents:onPlayerDied", interaction.closeUI)
