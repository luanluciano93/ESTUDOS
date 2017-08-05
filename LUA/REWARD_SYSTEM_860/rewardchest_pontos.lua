-- Sistema de recompensa criado por luanluciano93

dofile('data/sistemas/rewardchest.lua')

function onLogin(cid)
	for key, value in pairs(REWARDCHEST.bosses) do
		if getPlayerStorageValue(cid, value.storage) > 0 then
			setPlayerStorageValue(cid, value.storage, 0)
		end
	end
	registerCreatureEvent(cid, "RewardChestStats")
	return true
end

function onStatsChange(cid, attacker, type, combat, value)
	if isMonster(attacker) and (type == STATSCHANGE_HEALTHLOSS or type == STATSCHANGE_MANALOSS) then
		local boss = REWARDCHEST.bosses[getCreatureName(attacker):lower()]
		if boss then
			setPlayerStorageValue(cid, boss.storage, getPlayerStorageValue(cid, boss.storage) + math.ceil((value / REWARDCHEST.formula.block)))
			setPlayerStorageValue(cid, REWARDCHEST.storageExaust, os.time() + 5)
		end
	elseif (isPlayer(attacker) and (type == STATSCHANGE_HEALTHGAIN or type == STATSCHANGE_MANAGAIN) and (getCreatureHealth(cid) < getCreatureMaxHealth(cid)) and (getPlayerStorageValue(cid, REWARDCHEST.storageExaust) >= os.time())) then
		for key, value in pairs(REWARDCHEST.bosses) do
			if getPlayerStorageValue(cid, value.storage) > 0 then
				if getCreatureHealth(cid) + value > getCreatureMaxHealth(cid) then
					local add = getCreatureMaxHealth(cid) - getCreatureHealth(cid)
					setPlayerStorageValue(attacker, value.storage, getPlayerStorageValue(attacker, value.storage) + math.ceil((add / REWARDCHEST.formula.suport)))
				else
					setPlayerStorageValue(attacker, value.storage, getPlayerStorageValue(attacker, value.storage) + math.ceil((value / REWARDCHEST.formula.suport)))
				end
			end
		end
	end
	
	return true
end
