-- <globalevent name="Safezone" time="15:00:00" script="safezone.lua" />

dofile('data/lib/custom/safezone.lua')

function onTime(interval)
	if safezone_totalPlayers() == 0 then
		eventsOutfit = {}
		safezone_teleportCheck()
	else
		print(">> Safezone event is already running.")
	end
	return true
end
