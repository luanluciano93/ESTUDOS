-- DUCA EVENTO by luanluciano93

DUCA = {
	EVENT_MINUTES = 40,
	TELEPORT_POSITION = {x = 32365, y = 32236, z = 7},
	STORAGE_TEAM = 27000,
	TOTAL_PONTOS = 27001,
	TOTAL_PLAYERS = 27003, -- global storage
	LEVEL_MIN = 80,
	REWARD_FIRST = {2160, 10},
	REWARD_SECOND = {2160, 5},

	TEAMS = {
		[1] = {color = "Black", temple = {x = 16887, y = 16676, z = 7}},
		[2] = {color = "White", temple = {x = 16887, y = 16676, z = 7}},
		[3] = {color = "Red"},
		[4] = {color = "Green"},
    }, 
}

local conditioBlack = createConditionObject(CONDITION_OUTFIT)
setConditionParam(conditioBlack, CONDITION_PARAM_TICKS, -1)
addOutfitCondition(conditioBlack, {lookType = 128, lookHead = 114, lookBody = 114, lookLegs = 114, lookFeet = 114})

local conditioWhite = createConditionObject(CONDITION_OUTFIT)
setConditionParam(conditioWhite, CONDITION_PARAM_TICKS, -1)
addOutfitCondition(conditioWhite, {lookType = 128, lookHead = 19, lookBody = 19, lookLegs = 19, lookFeet = 19})

local conditioRed = createConditionObject(CONDITION_OUTFIT)
setConditionParam(conditioRed, CONDITION_PARAM_TICKS, -1)
addOutfitCondition(conditioRed, {lookType = 134, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94})

local conditioGreen = createConditionObject(CONDITION_OUTFIT)
setConditionParam(conditioGreen, CONDITION_PARAM_TICKS, -1)
addOutfitCondition(conditioGreen, {lookType = 134, lookHead = 101, lookBody = 101, lookLegs = 101, lookFeet = 101})

-- function DUCA.teleportCheck()
DUCA.teleportCheck = function()
	local item = getTileItemById(DUCA.TELEPORT_POSITION, 1387).uid
	if item > 0 then
		doRemoveItem(item)
		DUCA.finishEvent()

		print(">>> Duca Event was finished. <<<")
	else		
		doBroadcastMessage("Duca Event was started and will close in ".. DUCA.EVENT_MINUTES .." minutes.")
		print(">>> Duca Event was started. <<<")

		local teleport = doCreateItem(1387, 1, DUCA.TELEPORT_POSITION)
		doItemSetAttribute(teleport, "aid", 48000)

		setGlobalStorageValue(DUCA.TOTAL_PLAYERS, 0)
		addEvent(DUCA.teleportCheck, DUCA.EVENT_MINUTES * 60 * 1000)
	end
end

-- function DUCA.addPlayerinTeam(cid, team)
DUCA.addPlayerinTeam = function(cid, team)
	doRemoveCondition(cid, CONDITION_OUTFIT)
	doRemoveCondition(cid, CONDITION_INVISIBLE)
	if team == 1 then
		doAddCondition(cid, conditioBlack)
	elseif team == 2 then
		doAddCondition(cid, conditioWhite)
	elseif team == 3 then
		doAddCondition(cid, conditioRed)
	elseif team == 4 then
		doAddCondition(cid, conditioGreen)
	end
	setPlayerStorageValue(cid, DUCA.STORAGE_TEAM, team)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You will join the " .. DUCA.TEAMS[team].color .. " Team.")
	doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
	doCreatureAddMana(cid, getCreatureMaxMana(cid))
end


-- function DUCA.balanceTeam()
DUCA.balanceTeam = function()
	local time1, time2 = 0, 0
	for _, cid in pairs(getPlayersOnline()) do
		if getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == 1 then
			time1 = time1 + 1
		elseif getPlayerStorageValue(cid, DUCA.STORAGE_TEAM) == 2 then
			time2 = time2 + 1
		end
	end

	return (time1 <= time2) and 1 or 2
end

-- function DUCA.removePlayer(cid)
DUCA.removePlayer = function(cid)
	doRemoveCondition(cid, CONDITION_OUTFIT)
	--doRemoveCondition(cid, CONDITION_HUNTING)
	--doRemoveCondition(cid, CONDITION_INFIGHT)
	--doRemoveCondition(cid, CONDITIONID_COMBAT)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You are dead in Duca Event and your Duca points is set to 0!")
	doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
	doCreatureAddMana(cid, getCreatureMaxMana(cid))	
	setPlayerStorageValue(cid, DUCA.STORAGE_TEAM, 0)
	setPlayerStorageValue(cid, DUCA.TOTAL_PONTOS, 0)
	unregisterCreatureEvent(cid, "Duca-Death")
	unregisterCreatureEvent(cid, "Duca-Combat")
	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))

	setGlobalStorageValue(DUCA.TOTAL_PLAYERS, getGlobalStorageValue(DUCA.TOTAL_PLAYERS) - 1)
end

-- function DUCA.updateRank()
DUCA.updateRank = function()
	local participantes = {}
	for _, uid in pairs(getPlayersOnline()) do
		if getPlayerStorageValue(uid, DUCA.STORAGE_TEAM) > 0 then
			table.insert(participantes, uid)
		end
	end

	table.sort(participantes, function(a, b) return getPlayerStorageValue(a, DUCA.TOTAL_PONTOS) > getPlayerStorageValue(b, DUCA.TOTAL_PONTOS) end)
	
	for x = 1, #participantes do
		if getPlayerStorageValue(participantes[x], DUCA.STORAGE_TEAM) >= 3 then
			DUCA.addPlayerinTeam(participantes[x], DUCA.balanceTeam())
		end
	end
	
	if (#participantes >= 1) then
		DUCA.addPlayerinTeam(participantes[1], 4)
	end
    
    	if (#participantes >= 11) then
    		for i = 2, 11 do
			DUCA.addPlayerinTeam(participantes[i], 3)
		end
	end
end

-- function DUCA.finishEvent()
DUCA.finishEvent = function()
	DUCA.updateRank()
	for _, uid in pairs(getPlayersOnline()) do
		if getPlayerStorageValue(uid, DUCA.STORAGE_TEAM) == 4 then
			local winner = getCreatureName(uid)
			doBroadcastMessage("Congratulation ".. winner .."!! Duca Event is finish. ".. winner .." win reward.")
			doPlayerAddItem(uid, DUCA.REWARD_FIRST[1], DUCA.REWARD_FIRST[2])
		elseif getPlayerStorageValue(uid, DUCA.STORAGE_TEAM) == 3 then
			doPlayerAddItem(uid, DUCA.REWARD_SECOND[1], DUCA.REWARD_SECOND[2])
		end

		if getPlayerStorageValue(uid, DUCA.STORAGE_TEAM) > 0 then
			DUCA.removePlayer(uid)
		end
	end
end
