-- Modules
local ShopPeds = require("client.modules.cl_shop-ped")

---@param speechName string
---@param speechParam string
local function ApplySpeechToPed(speechName, speechParam)
	local shopPed = ShopPeds.GetNearest()
	if shopPed and DoesEntityExist(shopPed) then
		if IsAmbientSpeechPlaying(shopPed) then StopCurrentPlayingAmbientSpeech(shopPed) end
		PlayPedAmbientSpeechNative(shopPed, speechName, speechParam)
	else
		Print.Error("[ApplySpeechToPed] No valid shop ped to apply speech.")
	end
end

return ApplySpeechToPed
