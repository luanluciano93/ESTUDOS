dofile('data/lib/custom/battlefield.lua')

function onTime(interval)
	if BATTLEFIELD:totalPlayers() == 0 then
		eventsOutfit = {}
		BATTLEFIELD:teleportCheck()
	else
		print(">> Battlefield event is already running.")
	end
	return true
end
