-- <talkaction words="!guildpoints" separator=" " script="custom/guildpoints.lua"/>

--[[ 
CREATE TABLE IF NOT EXISTS `znote_shop` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` int NOT NULL,
  `itemid` int DEFAULT NULL,
  `count` int NOT NULL DEFAULT '1',
  `description` varchar(255) NOT NULL,
  `points` int NOT NULL DEFAULT '10',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

informações sobre adesão dos pontos.
ok -- Comando Utilizado:	!guildpoints (leader)
ok -- Level Mínimo:	Level 70
ok -- Players On-line:	4 On-line
ok -- IPs Diferentes:	2 IPs
Quantidade de Pontos:	10 Pontos (cada player)
ok -- O comando só pode ser executado uma vez por dia 

e cada player só recebe uma vez por account, não adianta entra em outra guild e nem tentar com outro character.

]]--

local config = {
	executeInterval = 24, -- em horas
	minimumLevel = 70,
	membersNeeded = 4,
	checkDifferentIps = true,
	minimumDifferentIps = 4,
	pointAmount = 10
	accountStorage = 9999,
}

local function getValidAccounts(guild)
	local resultId = db.storeQuery('SELECT a.`id` 
	
	FROM `accounts` a, 
	`guild_membership` m, 
	`players` p 
	WHERE m.`guild_id` = ' ..guild:getId() .. ' 
	AND p.`id` = m.`player_id` AND p.`level` > ' 
	
	
	..  config.minimumLevel .. ' and a.`id` = p.`account_id` AND a.`guild_points_stats` = 0 GROUP BY a.`id`;')
	
	if resultId == false then
		return {}
	end
	local accounts = {}
	repeat
		table.insert(accounts, result.getDataInt(resultId, 'id'))
	until not result.next(resultId)
	result.free(resultId)
	return accounts
end

function onSay(player, words, param)

	local guild = player:getGuild()
	if not guild then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'You are not in any guild.')
		return false
	end

	if player:getGuildLevel() ~= 3 then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'Only guild leader can request points.')
		return false
	end

	local guildId = guild:getId()
	local resultId = db.storeQuery('SELECT `last_execute_points` FROM `guilds` WHERE `id` = '.. guildId)
	if not resultId then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage('Error while running database query.')
		return false
	end

	local lastExecution = result.getDataInt(resultId, 'last_execute_points')
	result.free(resultId)

	if lastExecution >= os.time() then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'The command can only be run once every '.. config.executeInterval ..' hours.')
		return false
	end

	local membersTable, validIpsTable = {}, {}
	for _, member in ipairs(guild:getMembersOnline()) do
		if member:getLevel() >= config.minimumLevel then
			local accountId = player:getAccountId()
			local getAccountStorage = Game.getAccountStorageValue(accountId, config.accountStorage)
			if getAccountStorage then
				if getAccountStorage > 0 then
				
				
			

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

	local totalMembrosOnline = #membersTable
	if totalMembrosOnline < config.membersNeeded then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'Only '.. totalMembrosOnline ..' guild members online, you need '.. config.membersNeeded ..' guild members with level '.. config.minimumLevel ..' or higher.')
		return false
	end

	local totalMembrosIps = #validIpsTable
	if totalMembrosIps < config.minimumDifferentIps then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'Only ' .. totalMembrosIps .. ' members are valid, you need ' ..config.minimumDifferentIps .. ' players with different ip addresses.')
		return false
	end

CREATE TABLE IF NOT EXISTS `account_storage` (
  `account_id` int NOT NULL,
  `key` int unsigned NOT NULL,
  `value` int NOT NULL,
  PRIMARY KEY (`account_id`, `key`),
  FOREIGN KEY (`account_id`) REFERENCES `accounts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;

Game.getAccountStorageValue(accountId, key)
Game.setAccountStorageValue(accountId, key, value)

	local validAccounts = getValidAccounts(guild)

	db.query('UPDATE `guilds` SET `last_execute_points` = ' .. (os.time() + config.executeInterval * 3600) .. ' WHERE `guilds`.`id` = '.. guildId ..';')
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, #validAccounts .. ' guild members received points.')
	if #validAccounts > 0 then
		db.query('UPDATE `accounts` SET `guild_points` = `guild_points` + ' .. config.pointAmount .. ', `guild_points_stats` = ' .. os.time() .. ' WHERE `id` IN (' .. table.concat(validAccounts, ',') .. ');')
		for i = 1, #members do
			local member = members[i]
			if isInArray(validAccounts, member:getAccountId()) then
				member:sendTextMessage(MESSAGE_INFO_DESCR, 'You received ' .. config.pointAmount .. ' guild points.')
			end
		end
	end
	return false
end
