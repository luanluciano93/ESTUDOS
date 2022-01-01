-- <talkaction words="!guildpoints" separator=" " script="custom/guildpoints.lua"/>

-- ALTER TABLE `guilds` ADD `last_execute_points` int NOT NULL DEFAULT '0';
-- ALTER TABLE `znote_accounts` ADD `guild_points` smallint unsigned NOT NULL DEFAULT '0';

local config = {
	executeInterval = 24, -- em horas
	minimumLevel = 70,
	membersNeeded = 4,
	checkDifferentIps = true,
	minimumDifferentIps = 4,
	pointAmount = 10
	accountStorage = 9999
}

function onSay(player, words, param)

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD POINTS] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildId = guild:getId()
	if not guildId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD POINTS] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:getGuildLevel() < 3 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] You need to be the guild leader to execute this command.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local resultId = db.storeQuery('SELECT `last_execute_points` FROM `guilds` WHERE `id` = '.. guildId)
	if not resultId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] The command can only be run once every '.. config.executeInterval ..' hours.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local lastExecution = result.getNumber(resultId, 'last_execute_points')
	result.free(resultId)

	if lastExecution >= os.time() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] The command can only be run once every '.. config.executeInterval ..' hours.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local membersTable, validIpsTable = {}, {}
	for _, member in ipairs(guild:getMembersOnline()) do
		if member:getLevel() >= config.minimumLevel then
			local accountId = member:getAccountId()
			local getAccountStorage = Game.getAccountStorageValue(accountId, config.accountStorage)
			if not getAccountStorage then
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if getAccountStorage < 1 then
				table.insert(membersTable, member:getGuid())
				local ipCount = 0
				local ip = member:getIp()
				for i = 1, #validIpsTable do
					if validIpsTable[i] then
						if ip == validIpsTable[i] then
							ipCount = ipCount + 1
						end
					end
				end

				if ipCount == 0 and checkDifferentIps then
					table.insert(validIpsTable, ip)
				end
			end
		end
	end

	local totalMembrosOnline = #membersTable
	if totalMembrosOnline < config.membersNeeded then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] Only '.. totalMembrosOnline ..' guild members online, you need '.. config.membersNeeded ..' guild members with level '.. config.minimumLevel ..' or higher.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local totalMembrosIps = #validIpsTable
	if totalMembrosIps < config.minimumDifferentIps then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] Only ' .. totalMembrosIps .. ' members are valid, you need ' ..config.minimumDifferentIps .. ' players with different ip addresses.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	db.query('UPDATE `guilds` SET `last_execute_points` = ' .. (os.time() + config.executeInterval * 3600) .. ' WHERE `guilds`.`id` = '.. guildId ..';')

	for _, member in ipairs(membersTable) do
		local accountId = member:getAccountId()
		Game.setAccountStorageValue(accountId, config.accountStorage, 1)
		db.query('UPDATE `znote_accounts` SET `guild_points` = `guild_points` + ' .. config.pointAmount .. ', `guild_points_stats` = ' .. os.time() .. ' WHERE `account_id` = '.. accountId)
		member:sendTextMessage(MESSAGE_INFO_DESCR, 'You received ' .. config.pointAmount .. ' guild points.')
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, #membersTable .. ' guild members received points.')

	return false
end
