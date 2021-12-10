local events = {
    'PlayerDeath',
	'DropLoot',
	'AdvanceSave',
	'LevelReward',
	'BossParticipation',
	'KosheiKill',
	'PythiusTheRotten',
	'Tasks',
	'BossAchievements',
	'DeathCast'
}

function onLogin(player)
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
		player:setBankBalance(0)
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Stamina
	nextUseStaminaTime[player.uid] = 0

	-- Events
	for i = 1, #events do
		player:registerEvent(events[i])
	end

	if not player:isPremium() then
		if player:getStorageValue(Storage.premiumCheck) == 1 then
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(Storage.premiumCheck, 0)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Your premium account time is over.")
		end
	else
		player:setStorageValue(Storage.premiumCheck, 1)
	end

	if not player:isPremium() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You are not yet a premium account, enter our website and enjoy the benefits of being premium.")
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You have "..player:getPremiumDays().." days of premium account.")
	end

	return true
end

local creatureevent = CreatureEvent("PlayerLogin")

function creatureevent.onLogin(player)


	if player:isPremium() then
		player:setStorageValue(Storage.PremiumAccount, 1)
	end

	-- Premium Ends Teleport to Temple, change addon (citizen) houseless
	local defaultTown = "Thais" -- default town where player is teleported if his home town is in premium area
	local freeTowns = {"Ab'Dendriel", "Carlin", "Kazordoon", "Thais", "Venore", "Rookgaard", "Dawnport", "Dawnport Tutorial", "Island of Destiny"} -- towns in free account area

	if not player:isPremium() and isInArray(freeTowns, player:getTown():getName()) == false then
		local town = player:getTown()
		local sex = player:getSex()
		local home = getHouseByPlayerGUID(getPlayerGUID(player))
		town = isInArray(freeTowns, town:getName()) and town or Town(defaultTown)
		player:teleportTo(town:getTemplePosition())
		player:setTown(town)
		player:sendTextMessage(MESSAGE_FAILURE, "Your premium time has expired.")
		player:setStorageValue(Storage.PremiumAccount, 0)
	end
	-- End 'Premium Ends Teleport to Temple'

	--local playerId = player:getId()
	--DailyReward.init(playerId)

	if player:getGroup():getId() >= GROUP_TYPE_GAMEMASTER then
		player:setGhostMode(true)
	end

	-- Boosted creature
	--player:sendTextMessage(MESSAGE_BOOSTED_CREATURE, "Today's boosted creature: " .. Game.getBoostedCreature() .. " \
	--Boosted creatures yield more experience points, carry more loot than usual and respawn at a faster rate.")

	-- Stamina
	nextUseStaminaTime[playerId] = 1

	-- EXP Stamina
	nextUseXpStamina[playerId] = 1

	local staminaMinutes = player:getStamina()
	local doubleExp = false --Can change to true if you have double exp on the server
	local staminaBonus = (staminaMinutes > 2340) and 150 or ((staminaMinutes < 840) and 50 or 100)
	if doubleExp then
		baseExp = baseExp * 2
	end
	player:setStaminaXpBoost(staminaBonus)
	player:setBaseXpGain(baseExp)

	return true
end

creatureevent:register()
