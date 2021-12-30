-- <talkaction words="!guildpoints" separator=" " script="custom/guildpoints.lua"/>

--[[ 

ALTER TABLE `accounts` ADD `guild_points` INTEGER(11) NOT NULL DEFAULT '0';

ALTER TABLE `accounts` ADD `guild_points_stats` INT NOT NULL DEFAULT '0';

ALTER TABLE `guilds` ADD `last_execute_points` INT NOT NULL DEFAULT '0';


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

	local lastExecution = result.getDataInt(resultId, 'last_execute_points')
	result.free(resultId)

	if lastExecution >= os.time() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD POINTS] The command can only be run once every '.. config.executeInterval ..' hours.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local membersTable, validIpsTable = {}, {}
	for _, member in ipairs(guild:getMembersOnline()) do
		if member:getLevel() >= config.minimumLevel then

			-- testar o "Game.getAccountStorageValue" se não tiver nada salvo, volta o ou -1 ou false?
			-- Game.getAccountStorageValue(accountId, key)
			-- Game.setAccountStorageValue(accountId, key, value)
			
			
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

	-- local validAccounts = getValidAccounts(guild)

	db.query('UPDATE `guilds` SET `last_execute_points` = ' .. (os.time() + config.executeInterval * 3600) .. ' WHERE `guilds`.`id` = '.. guildId ..';')

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, #validAccounts .. ' guild members received points.')

	if #validAccounts > 0 then
		db.query('UPDATE `accounts` SET `guild_points` = `guild_points` + ' .. config.pointAmount .. ', `guild_points_stats` = ' .. os.time() .. ' WHERE `id` IN (' .. table.concat(validAccounts, ',') .. ');')
		for i = 1, #membersTable do
			local member = membersTable[i]
			if table.contains(validAccounts, member:getAccountId()) then
				member:sendTextMessage(MESSAGE_INFO_DESCR, 'You received ' .. config.pointAmount .. ' guild points.')
			end
		end
	end
	return false
end
