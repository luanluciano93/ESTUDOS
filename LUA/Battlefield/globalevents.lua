-- <globalevent name="Battlefield" time="10:00:00" script="battlefield.lua" />

dofile('data/lib/custom/battlefield.lua')

function onTime(interval)
	if battlefield_totalPlayers() == 0 then
		eventsOutfit = {}
		battlefield_teleportCheck()
	else
		print(">> Battlefield event is already running.")
	end
	return true
end
