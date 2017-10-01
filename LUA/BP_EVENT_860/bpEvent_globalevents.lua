--[[
	<!-- Backpack Event -->
	<globalevent name="bpEvent" time="00:00:00" script="bpEvent_globalevents.lua" />
]]--

dofile('data/lib/bpEvent.lua')

function onTime(interval)
	bpEvent.teleportCheck()
	return true
end
