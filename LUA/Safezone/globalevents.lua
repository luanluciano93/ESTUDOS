dofile('data/lib/custom/safezone.lua')

function onTime(interval)
	if safezoneTotalPlayers() == 0 then
		safezoneTeleportCheck()
	else
		print(">> SafeZone event is already running.")
	end
	return true
end
