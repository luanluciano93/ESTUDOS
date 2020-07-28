dofile('data/lib/custom/battlefield.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if BATTLEFIELD:totalPlayers() == 0 then
			eventsOutfit = {}
			BATTLEFIELD:teleportCheck()
		else
			player:sendCancelMessage("Battlefield event is already running.")
		end
	end
	return false
end
