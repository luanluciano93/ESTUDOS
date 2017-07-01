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

	local pontos = {
		[1] = 10,
		[2] = 10,
		[3] = 20,
		[4] = 30,
	}

	if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) > 0 then
		local pontos_ganhos = pontos[getPlayerStorageValue(cid, DUCA.STORAGE_TEAM)]
		setPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS, getPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS) + pontos_ganhos)
		doPlayerSendTextMessage(deathList[1], MESSAGE_STATUS_CONSOLE_BLUE, "You have ".. getPlayerStorageValue(deathList[1], DUCA.TOTAL_PONTOS) .." titan points.")
		DUCA.removePlayer(cid)
		DUCA.updateRank()
	end
	return false
end

function onCombat(cid, target)
	if isPlayer(cid) and isPlayer(target) then
		if (getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == 1  and getPlayerStorageValue(target, DUCA.STORAGE_TEAM) == 1) or 
			(getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == 2  and getPlayerStorageValue(target, DUCA.STORAGE_TEAM) == 2) or
			(getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == 3  and getPlayerStorageValue(target, DUCA.STORAGE_TEAM) == 3) then
			return false
		end
	end
	return true
end
