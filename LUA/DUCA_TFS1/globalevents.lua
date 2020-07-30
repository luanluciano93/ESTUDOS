-- <globalevent name="Duca" time="10:00:00" script="duca.lua" />

dofile('data/lib/custom/duca.lua')

function onTime(interval)
	if duca_totalPlayers() == 0 then
		eventsOutfit = {}
		duca_teleportCheck()
	else
		print(">> Duca event is already running.")
	end
	return true
end
