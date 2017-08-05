-- Sistema de recompensa criado por luanluciano93

dofile('data/sistemas/rewardchest.lua')

local function addRewardLoot(uid, bossName, tabela_reward)
	local money = math.random(10, 40)
	local msg = "The following items are available in your reward chest:"
	local chest = doCreateItemEx(REWARDCHEST.rewardBagId)

	doItemSetAttribute(chest, "description", "Reward System has kill the boss ".. bossName ..".")

	if table.maxn(tabela_reward) > 0 then
		for x = 1, table.maxn(tabela_reward) do
			local rand = math.random(100)
			if rand <= tabela_reward[x][3] then
				doAddContainerItem(chest, tabela_reward[x][1], math.random(tabela_reward[x][2]))
				msg = msg .. " ".. (tabela_reward[x][2] > 1 and tabela_reward[x][2] > 1 or "") ..." "..getItemNameById(tabela_reward[x][1])..","
			end
		end
		doPlayerSendTextMessage(uid, MESSAGE_INFO_DESCR, msg .. " and ".. money .." platinum coins.")
	else
		doPlayerSendTextMessage(uid, MESSAGE_INFO_DESCR, msg .. " ".. money .." platinum coins.")
	end

	doAddContainerItem(chest, 2152, money)
	doPlayerSendMailByName(getPlayerName(uid), chest, REWARDCHEST.town_id)

	local boss = REWARDCHEST.bosses[bossName]
	setPlayerStorageValue(uid, boss.storage, 0)
	doSendMagicEffect(getPlayerPosition(uid), CONST_ME_MAGIC_BLUE)
end

local function addLoot(tabela_loot, tabela_reward, all_loot)
	if table.maxn(tabela_loot) > 0 then
		if all_loot then
			for x = 1, table.maxn(tabela_loot) do
				table.insert(tabela_reward, tabela_loot[x])
			end
		else
			table.insert(tabela_reward, tabela_loot[math.random(table.maxn(tabela_loot))])
		end
	end

	return tabela_reward
end

local function rewardChestSystem(bossName)
	local players = {}
	local boss = REWARDCHEST.bosses[bossName]

	for _, uid in ipairs(getPlayersOnline()) do
		if getPlayerStorageValue(uid, boss.storage) > 0 then
			table.insert(players, uid)
		end
	end

	table.sort(players, function(a, b) return getPlayerStorageValue(a, boss.storage) > getPlayerStorageValue(b, boss.storage) end)

	local porcentagem = math.ceil(getPlayerStorageValue(players[1], boss.storage))

	for i = 1, table.maxn(players) do

		local tabela_reward = {}
		local pontos = getPlayerStorageValue(players[i], boss.storage)

		if i == 1 then
			addLoot(boss.comum, tabela_reward, false)
			addLoot(boss.semi_raro, tabela_reward, false)
			addLoot(boss.raro, tabela_reward, false)
			addLoot(boss.sempre, tabela_reward, true)
		elseif i >= 2 and pontos >= math.ceil((porcentagem * 0.8)) then
			addLoot(boss.comum, tabela_reward, false)
			addLoot(boss.semi_raro, tabela_reward, false)
			addLoot(boss.raro, tabela_reward, false)
			addLoot(boss.muito_raro, tabela_reward, false)
		elseif pontos < math.ceil((porcentagem * 0.8)) and pontos >= math.ceil((porcentagem * 0.6)) then
			addLoot(boss.comum, tabela_reward, false)
			addLoot(boss.semi_raro, tabela_reward, false)
			addLoot(boss.raro, tabela_reward, false)
		elseif pontos < math.ceil((porcentagem * 0.6)) and pontos >= math.ceil((porcentagem * 0.4)) then
			addLoot(boss.comum, tabela_reward, false)
			addLoot(boss.semi_raro, tabela_reward, false)
		elseif pontos < math.ceil((porcentagem * 0.4)) and pontos >= math.ceil((porcentagem * 0.1)) then
			addLoot(boss.comum, tabela_reward, false)
		end

		addRewardLoot(players[i], bossName, tabela_reward)
	end
end

function onDeath(cid, corpse, killer)
	local boss = REWARDCHEST.bosses[getCreatureName(cid):lower()]
	if boss then
		addEvent(rewardChestSystem, 1000, getCreatureName(cid):lower())
	end
	return true
end

function onStatsChange(cid, attacker, type, combat, value)
	if isMonster(cid) and type == STATSCHANGE_HEALTHLOSS then
		local boss = REWARDCHEST.bosses[getCreatureName(cid):lower()]
		if boss then
			setPlayerStorageValue(attacker, boss.storage, getPlayerStorageValue(attacker, boss.storage) + math.ceil((value / REWARDCHEST.formula.hit)))
		end
	end
	return true
end
