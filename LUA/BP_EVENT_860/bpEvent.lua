bpEvent = {
	EVENT_MINUTES = 5,
	TELEPORT = {POSITION = {x = 100, y = 100, z = 7}, MINUTES = 2},
	ENTER_EVENT_POSITION = {x = 100, y = 100, z = 7},
	COAL_BASIN_POSITION = {x = 100, y = 100, z = 7, stackpos = 255},
	STONE = {ID = 1543, POSITION = {x = 100, y = 100, z = 7}},
	LEVEL_MIN = 80,
	REWARD_MONEY = {MIN = 1, MAX = 100000},
	BACKPACK_IDS = {1988, 2245, 5467},
	STORAGE = 27333,
	TOTAL_PLAYERS = 27334, -- global storage
}

-- function bpEvent.teleportCheck()
bpEvent.teleportCheck = function()
	if getTileItemById(bpEvent.TELEPORT.POSITION, 1387).uid == 0 then
		doBroadcastMessage("The backpack event is open and will start in ".. TELEPORT.MINUTES .." minutes.") 

		local teleport = doCreateItem(1387, 1, bpEvent.TELEPORT.POSITION)
		doItemSetAttribute(teleport, "aid", 48003)

		setGlobalStorageValue(bpEvent.TOTAL_PLAYERS, 0)
		addEvent(bpEvent.teleportCheck, bpEvent.TELEPORT.MINUTES * 60 * 1000)
	else
		doRemoveItem(getThingfromPos(bpEvent.TELEPORT.POSITION).uid, 1)
		doBroadcastMessage("The backpack event started will end in ".. EVENT_MINUTES .." minutes.") 
		addEvent(bpEvent.finishEvent, bpEvent.EVENT_MINUTES * 60 * 1000)
	end
end

-- function bpEvent.stoneCheck()
bpEvent.stoneCheck = function()
	if getTileItemById(bpEvent.STONE.POSITION, bpEvent.STONE.ID).uid == 0 then
		doCreateItem(bpEvent.STONE.ID, 1, bpEvent.STONE.POSITION)
	else
		doRemoveItem(getThingfromPos(bpEvent.STONE.POSITION).uid, 1)
	end
end

-- function bpEvent.finishEvent()
bpEvent.finishEvent = function()
	doBroadcastMessage("The backpack event is closed with the participation of ".. getGlobalStorageValue(bpEvent.TOTAL_PLAYERS) .." players.")  
	bpEvent.stoneCheck()
	for _, uid in pairs(getPlayersOnline()) do
		if getPlayerStorageValue(uid, bpEvent.STORAGE) > 0 then
			doTeleportThing(uid, getTownTemplePosition(getPlayerTown(uid)))
			setPlayerStorageValue(uid, bpEvent.STORAGE, 0)
		end
	end
end
