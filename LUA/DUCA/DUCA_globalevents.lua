--[[
	<!-- DUCA Event -->
	<globalevent name="Duca" time="00:00:00" script="DUCA_globalevents.lua" />
]]--

dofile('data/lib/DUCA.lua')

function onTime(interval) -- se der bug use: function onTimer(interval)
	DUCA.teleportCheck()
	return true
end
