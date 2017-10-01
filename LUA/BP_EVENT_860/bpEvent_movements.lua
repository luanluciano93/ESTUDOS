--[[
	<!-- Backpack Event -->
	<movevent event="StepIn" actionid="48003" script="bpEvent_movements.lua"/>
	<movevent event="StepIn" actionid="48004" script="bpEvent_movements.lua"/>
]]--

dofile('data/lib/bpEvent.lua')

function onStepIn(cid, item, position, fromPosition)
	if not isPlayer(cid) then
		return false
	end

	if item.actionid == 48003 then
		if getPlayerLevel(cid) < bpEvent.LEVEL_MIN then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You need level " .. bpEvent.LEVEL_MIN .. " to enter in backpack event.")
			doTeleportThing(cid, fromPosition)
			return false
		end

		for _, uid in pairs(getPlayersOnline()) do
			if getPlayerIp(cid) == getPlayerIp(uid) and getPlayerStorageValue(uid, bpEvent.STORAGE) > 0 then
				doTeleportThing(cid, fromPosition)
				return false
			end
		end

		doTeleportThing(cid, bpEvent.ENTER_EVENT_POSITION)
		setPlayerStorageValue(cid, bpEvent.STORAGE, 1)
	
	elseif item.actionid == 48004 then
		doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
		setPlayerStorageValue(cid, bpEvent.STORAGE, 0)
	end

	return true
end
