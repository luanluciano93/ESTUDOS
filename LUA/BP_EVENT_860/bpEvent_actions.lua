--[[
	<!-- Backpack Event -->
	<action uniqueid="9875" script="bpEvent_actions.lua"/>
]]--

dofile('data/lib/bpEvent.lua')

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local backpack = getThingFromPos(bpEvent.COAL_BASIN_POSITION)
	if not isInArray(bpEvent.BACKPACK_IDS, backpack.itemid) then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local bp = doPlayerAddItem(cid, backpack.itemid, 1)
	local money = math.random(bpEvent.REWARD_MONEY.MIN, bpEvent.REWARD_MONEY.MAX)
	if money <= 100 then
		doAddContainerItem(bp, 2148, money)
	elseif money <= 10000 then
		doAddContainerItem(bp, 2152, math.ceil((money / 100)))
		money = money - math.ceil((money / 100))
		doAddContainerItem(bp, 2148, money)
	else
		doAddContainerItem(bp, 2160, math.ceil((money / 10000)))
		money = money - math.ceil((money / 10000))
		doAddContainerItem(bp, 2152, math.ceil((money / 100)))
		money = money - math.ceil((money / 100))
		doAddContainerItem(bp, 2148, money)
	end

	doRemoveItem(backpack.uid, 1)
	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
	setGlobalStorageValue(bpEvent.TOTAL_PLAYERS, getGlobalStorageValue(bpEvent.TOTAL_PLAYERS) + 1)
	setPlayerStorageValue(cid, bpEvent.STORAGE, 0)

	return true
end
