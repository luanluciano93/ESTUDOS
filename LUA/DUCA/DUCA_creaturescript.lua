--[[
	<!-- DUCA Event -->
	<event type="login" name="Duca-Login" event="script" value="DUCA_creaturescript.lua"/>
	<event type="logout" name="Duca-Logout" event="script" value="DUCA_creaturescript.lua"/>
	<event type="preparedeath" name="Duca-Death" event="script" value="DUCA_creaturescript.lua"/>
	<event type="combat" name="Duca-Combat" event="script" value="DUCA_creaturescript.lua"/>
]]--
	
dofile('data/lib/DUCA.lua')

function onLogin(cid)
	if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) > 0 then
		DUCA.removePlayer(cid)
	end
	return true
end

function onLogout(cid)
	if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) > 0 then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You can not logout now!")
		return false
	end
	return true
end

function onPrepareDeath(cid, deathList, lastHitKiller, mostDamageKiller)

	local pontos = {[1] = 1, [2] = 1, [3] = 10, [4] = 30,}

	if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) > 0 then
		local pontos_ganhos = pontos[getPlayerStorageValue(cid, DUCA.STORAGE_TEAM)]
		setPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS, getPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS) + pontos_ganhos)
		doPlayerSendTextMessage(deathList[1], MESSAGE_STATUS_CONSOLE_BLUE, "You have ".. getPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS) .." duca points.")
		DUCA.removePlayer(cid)
		DUCA.updateRank()
	end
	return false
end

function onCombat(cid, target)
	if isPlayer(cid) and isPlayer(target) then
		if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) > 0 then
			if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == getPlayerStorageValue(target, DUCA.STORAGE_TEAM) then
				return false
			end
		end
	end
	return true
end
