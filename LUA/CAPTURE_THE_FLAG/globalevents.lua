-- <globalevent name="CaptureTheFlag" time="04:00:00" script="capturetheflag.lua" />

dofile('data/lib/custom/capturetheflag.lua')

function onTime(interval)
	if capturetheflag_totalPlayers() == 0 then
		capturetheflag_teleportCheck()
	else
		print(">>> Capture the Flag event is already running.")
	end
	return true
end
