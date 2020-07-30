-- <globalevent name="Zombie" time="09:00:00" script="events/zombie.lua" />

dofile('data/lib/custom/zombie.lua')

function onTime(interval)
	if zombie_totalPlayers() == 0 then
		zombie_teleportCheck()
	else
		print(">> Zombie event is already running.")
	end
	return true
end
