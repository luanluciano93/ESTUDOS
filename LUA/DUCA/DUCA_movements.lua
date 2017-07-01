--[[
	<!-- DUCA Event -->
	<movevent event="StepIn" actionid="48000" script="DUCA_movements.lua"/>
]]--

dofile('data/lib/DUCA.lua')

function onStepIn(cid, item, position, fromPosition)
	if not isPlayer(cid) then
		return false
	end

	if getPlayerLevel(cid) < DUCA.LEVEL_MIN then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You need level " .. DUCA.LEVEL_MIN .. " to enter in Duca event.")
		doTeleportThing(cid, fromPosition)
		return false
	end

	if getPlayerItemCount(cid, 2165) >= 1 or getPlayerSlotItem(cid, CONST_SLOT_RING).itemid == 2202 then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You can not enter stealth ring in the event.")
		doTeleportThing(cid, fromPosition)
		return false
	end

	for _, uid in pairs(getPlayersOnline()) do
		if getPlayerIp(cid) == getPlayerIp(uid) and getPlayerStorageValue(uid, DUCA.STORAGE_TEAM) > 0 then
			doTeleportThing(cid, fromPosition)
			return false
		end
	end
	
	local team = DUCA.balanceTeam()
	DUCA.addPlayerinTeam(cid, team)

	doTeleportThing(cid, DUCA.TEAMS[team].temple)

	setPlayerStorageValue(cid, DUCA.TOTAL_PONTOS, 0)
	registerCreatureEvent(cid, "Duca-Death")
	registerCreatureEvent(cid, "Duca-Combat")

	setGlobalStorageValue(DUCA.TOTAL_PLAYERS, getGlobalStorageValue(DUCA.TOTAL_PLAYERS) + 1)

	return true
end
