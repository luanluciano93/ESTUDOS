-- Revscript City War by luanluciano93 --

-- !citywar invite, city, frags, UE, RUNES AREA, SSA/Might, playersMax, Frontline, guildEnemy   / ex: !citywar invite, Carlin, 50, desativado, disabled, disabled, 50, disabled, Wicked
-- !citywar accept, guildEnemy                                                                  / ex: !citywar accept, Wicked
-- !citywar cancel, guildEnemy                                                                  / ex: !citywar cancel, Wicked
-- !citywar go                                                                                  / ex: !citywar go

WarConfigs =
{
	WarFirstGuildPos = {
	{x = 3812, y = 3117, z = 7}, -- Dust2
	{x = 3594, y = 3251, z = 6}, -- Darashia
	{x = 3288, y = 3218, z = 7}, -- Roshamuul
	{x = 3351, y = 2993, z = 6}, -- Carlin
	{x = 3535, y = 2910, z = 7}, -- Thais
	{x = 3732, y = 2821, z = 6} -- Edron
	},
	
	WarSecondGuildPos = {
	{x = 3769, y = 3102, z = 6}, -- Dust2
	{x = 3519, y = 3224, z = 7}, -- Darashia
	{x = 3328, y = 3127, z = 7}, -- Roshamuul
	{x = 3300, y = 2957, z = 7}, -- Carlin
	{x = 3477, y = 2842, z = 6}, -- Thais
	{x = 3802, y = 2859, z = 6} -- Edron
	},

	WarCitys = {"dust2", "darashia", "roshamuul", "carlin", "thais", "edron"},
	WarMinLevel = 250,
	WarMaxFrontLine = 4,
	WarGuildLeaderMinLevel = 250,
	WarMinPlayers = 1,
	WarMinPlayersInGuild = 1,
	WarNeedDiferentIps = 1,
	WarLimitTime = 3 * 60 * 60,
	
	warAcceptInviteTime = 5 * 60,
	
	WarWaitTimeToCancel = 0 * 60,
	WarLossExpPercent = 10,
	WarLossSkillsPercent = 0,
	-- Global Storages
	["WarArenaStorage"] = {72000, 72001, 72002, 72003, 72004, 72005, 72006, 72007},
	["WarAcceptTimeArena"] = {73010, 73011, 73012, 73013, 73014, 73015, 73016, 73017},
	["WarFirstGuildID"] = {74020, 74021, 74022, 74023, 74024, 74025, 74026, 74027},
	["WarSecondGuildID"] = {75030, 75031, 75032, 75033, 75034, 75035, 75036, 75037},
	["WarMaxPlayerValue"] = {76040, 76041, 76042, 76043, 76044, 76045, 76046, 76047},
	["WarFirstTeamPlayerCount"] = {77050, 77051, 77052, 77053, 77054, 77055, 77056, 77057},
	["WarSecondTeamPlayerCount"] = {78060, 78061, 78062, 78063, 78064, 78065, 78066, 78067},
	["WarFragsToFinish"] = {79070, 79071, 79072, 79073, 79074, 79075, 79076, 79077},
	["WarUltimateExplosion"] = {80080, 80081, 80082, 80083, 80084, 80085, 80086, 80087},
	["WarAreaRunes"] = {81090, 81091, 81092, 81093, 81094, 81095, 81096, 81097},
	["WarFirstTeamPlayerDeathsCount"] = {82100, 82101, 82102, 82103, 82104, 82105, 82106, 82107},
	["WarSecondTeamPlayerDeathsCount"] = {83110, 83111, 83112, 83113, 83114, 83115, 83116, 83117},
	["WarMinutesInactive"] = {84120, 84121, 84122, 84123, 84124, 84125, 84126, 84127},
	["WarTeamInactive"] = {85130, 85131, 85132, 85133, 85134, 85135, 85136, 85137},
	["WarCanceledCity"] = {86140, 86141, 86142, 86143, 86144, 86145, 86146, 86147},
	["WarDontSSAMight"] = {725080, 725081, 725082, 725083, 725084, 725085, 725086, 725087},
	["WarLimitFrontLine"] = {735040, 735041, 735042, 735043, 735044, 735045, 735046, 735047},
	["WarFirstTeamFrontCount"] = {745040, 745041, 745042, 745043, 745044, 745045, 745046, 745047},
	["WarSecondTeamFrontCount"] = {755040, 755041, 755042, 755043, 755044, 755045, 755046, 755047},
	-- Players Storages
	WarPlayerJoined = 73000,
	WarUrgentExit = 73002,
	WarUEDisabled = 73003,
	WarAreaRunesDisabled = 73004,
	WarSSAMight = 732015,
	WarFrontLine = 732020
}


local config = {
	warCitys = {"dust2", "darashia", "roshamuul", "carlin", "thais", "edron"},

	globalStorage_warInviteTime = {1000, 1001},
	globalStorage_warInviteGuild = {1100, 1101},
	globalStorage_warInviteEnemy = {1200, 1201},

	globalStorage_warActiveTime = {1300, 1301},
	globalStorage_warAtiveGuild = {1400, 1401},
	globalStorage_warAtiveEnemy = {1500, 1501},
	
	globalStorage_warLimiteFrags = {1600, 1601},
	globalStorage_warMagiasArea = {1700, 1701},
	globalStorage_warRunasArea = {1800, 1801},
	globalStorage_warItensReducao = {1900, 1901},
	globalStorage_warLimitePlayers = {2000, 2001},
	globalStorage_warLimiteFrontline = {2100, 2101},

	warAcceptInviteTime = 5 * 60,
}

local citys = {
	["carlin"] = 1,
	["edron"] = 2,
},

local citywar_talkaction = TalkAction("!citywar")
function citywar_talkaction.onSay(player, words, param)
	local exhaustion = player:getExhaustion(Storage.exhaustion.talkaction)
	if exhaustion > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Você tem que esperar ".. exaust .. " segundos para usar novamente o comando.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(5, Storage.exhaustion.talkaction)

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você precisa de uma guild para usar esse comando.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildId = guild:getId()
	if not guildId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você precisa de uma guild para usar esse comando.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if guildId == 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você precisa de uma guild para usar esse comando.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local param = param:lower()
	local commandParam = param:splitTrimmed(",")
	if not commandParam[1] then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Parâmetros insuficientes. Comandos da citywar:" .. "\n"
			.. "!citywar invite" .. "\n"
			.. "!citywar accept" .. "\n"
			.. "!citywar cancel" .. "\n"
			.. "!citywar go")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if not table.contains({"invite", "accept", "cancel", "go"}, commandParam[1]) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Parâmetros insuficientes. Comandos da citywar:" .. "\n"
			.. "!citywar invite" .. "\n"
			.. "!citywar accept" .. "\n"
			.. "!citywar cancel" .. "\n"
			.. "!citywar go")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if player:getLevel() < WarConfigs.WarMinLevel then
		player:say("[CITY WAR] Para participar do citywar é necessário level ".. WarConfigs.WarMinLevel .." ou superior.", TALKTYPE_ORANGE_1)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if commandParam[1] == "invite" then

		if player:getGuildLevel() < 3 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Você não é líder de uma guild para usar esse comando.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[2] or commandParam[2] == "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Primeiro parâmetro de invite insuficiente. Você não especificou a cidade do citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local city = citys[commandParam[2]]
		if not city then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A cidade que você escolheu é inválida. As cidades disponíveis na citywar são ".. table.concat(config.WarCitys, ', ') ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[3] or commandParam[3] == "" or not tonumber(commandParam[3]) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Segundo parâmetro de invite insuficiente. Você não especificou a quantidade de frags para terminar a guerra do citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[4] or commandParam[4] == "" or (commandParam[4] ~= "ativado" and commandParam[4] ~= "desativado") then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Terceiro parâmetro de invite insuficiente. Você não especificou se estará ativado as magias de área no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[5] or commandParam[5] == "" or (commandParam[5] ~= "ativado" and commandParam[5] ~= "desativado") then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Quarto parâmetro de invite insuficiente. Você não especificou se estará ativado as runas de área no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[6] or commandParam[6] == "" or (commandParam[6] ~= "ativado" and commandParam[6] ~= "desativado") then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Quinto parâmetro de invite insuficiente. Você não especificou se estará ativado o uso de stone skin amulets e might rings no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[7] or commandParam[7] == "" or not tonumber(commandParam[7]) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sexto parâmetro de invite insuficiente. Você não especificou o limite máximo de jogadores de cada guild no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if tonumber(commandParam[7]) < WarConfigs.WarMinPlayers then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sexto parâmetro de invite inválido. O mínimo de jogadores necessários de cada guild no citywar é ".. WarConfigs.WarMinPlayers ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[8] or commandParam[8] == "" or (commandParam[8] ~= "ativado" and commandParam[8] ~= "desativado") then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sétimo parâmetro de invite insuficiente. Você não especificou se quer ativar o limite de frontlines no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[9] or commandParam[9] == "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Oitavo parâmetro de invite insuficiente. Você não especificou o nome da aliança que você quer invitar para a guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
			
		local function getEnemyId(enemyName)
			local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `name` = " .. db.escapeString(enemyName))
			if resultId == false then
				return false
			end

			local enemyId = result.getNumber(resultId, "id")
			result.free(resultId)
			return enemyId
		end

		local enemyId = getEnemyId(commandParam[9])
		if not enemyId then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Oitavo parâmetro de invite inválido. A guild '.. commandParam[9] ..' não existe.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function getEnemyName(enemyId)
			local resultId = db.storeQuery("SELECT `name` FROM `guilds` WHERE `id` = " .. enemyId)
			if resultId == false then
				return false
			end

			local enemyName = result.getString(resultId, "name")
			result.free(resultId)
			return enemyName
		end

		local enemyName = getEnemyName(enemyId)
		local guildName = guild:getName()

		if enemyId == guildId or enemyName == guildName then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Oitavo parâmetro de invite inválido. Você não pode invitar sua própria guilda para a guerra no citywar.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function validIpsGuild(guildId)
			local guild = Guild(guildId)
			if not guild then
				return false
			end
			local validIpsTable = {}
			for _, member in ipairs(guild:getMembersOnline()) do
				if member then
					local ipCount = 0
					local ip = member:getIp()
					if ip > 0 then
						for i = 1, #validIpsTable do
							if validIpsTable[i] then
								if ip == validIpsTable[i] then
									ipCount = ipCount + 1
								end
							end
						end

						if ipCount == 0 and config.checkDifferentIps then
							table.insert(validIpsTable, ip)
						end
					end
				end
			end
			return #validIpsTable
		end
		
		local validIps = validIpsGuild(guildId)
		if not validIps then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, sua guild deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online de IPS diferentes.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end			

		if validIps < WarConfigs.WarMinPlayersInGuild then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, sua guild deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online de IPS diferentes.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		validIps = validIpsGuild(enemyId)
		if not validIps then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, a guild invitada deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online de IPS diferentes.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end		

		if validIps < WarConfigs.WarMinPlayersInGuild then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, a guild invitada deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online de IPS diferentes.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function checkGlobalStorages(table, number)
			if not type(table) == "table" or not tonumber(number) then
				return false
			end
			for i = 1, #table do
				if Game.getStorageValue(table[i]) == number then
					return true
				end
			end
			return false
		end

		if checkGlobalStorages(config.globalStorage_warInviteGuild, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild já invitou uma guerra no citywar. Se não quiser aguarda-lá, cancele-a")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if checkGlobalStorages(config.globalStorage_warInviteEnemy, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild tem um convite de guerra pendente no citywar. Se não for aceitá-lo, cancele-o primeiramente.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if checkGlobalStorages(config.globalStorage_warAtiveGuild, guildId) or checkGlobalStorages(config.globalStorage_warAtiveEnemy, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild já está em uma guerra ativa no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if checkGlobalStorages(config.globalStorage_warAtiveGuild, enemyId) or checkGlobalStorages(config.globalStorage_warAtiveEnemy, enemyId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A guild que vocÊ quer invitar já está em uma guerra ativa no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if Game.getStorageValue(config.globalStorage_warActiveTime[city]) > os.time()  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A cidade ".. commandParam[2] .." do citywar já está em uso. Aguarde sua liberação ou escolha outra cidade.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if Game.getStorageValue(config.globalStorage_warInviteTime[city]) > os.time()  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Existe um convite pendente para a cidade ".. commandParam[2] ..". Aguarde por gentileza ou escolha outra cidade.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		Game.setStorageValue(config.globalStorage_warInviteTime[city], os.time() + config.warAcceptInviteTime)
		Game.setStorageValue(config.globalStorage_warLimiteFrags[city], commandParam[3])
	
		if commandParam[4] == "desativado" then
			Game.setStorageValue(config.globalStorage_warMagiasArea[city], 1)
		end

		if commandParam[5] == "desativado" then
			Game.setStorageValue(config.globalStorage_warRunasArea[city], 1)
		end

		if commandParam[6] == "ativado" then
			Game.setStorageValue(config.globalStorage_warItensReducao[city], 1)
		end

		Game.setStorageValue(config.globalStorage_warLimitePlayers[city], commandParam[7])
		
		if commandParam[8] == "ativado" then
			Game.setStorageValue(config.globalStorage_warLimiteFrontline[city], 1)
		end
		
		Game.setStorageValue(config.config.globalStorage_warAtiveGuild[city], guildId)
		Game.setStorageValue(config.config.globalStorage_warAtiveGuild[city], enemyId)		

		local function warBroadcastGuild(guildId, msg)
			local guild = Guild(guildId)
			if not guild then
				return false
			end
			for _, member in ipairs(guild:getMembersOnline()) do
				if member then
					member:sendTextMessage(MESSAGE_INFO_DESCR, msg)
				end
			end
		end

		warBroadcastGuild(guildId, "[CITYWAR] O líder da guild convidou a guild ".. commandParam[9] .." para uma guerra em na cidade ".. commandParam[2] .." do citywar!")
		warBroadcastGuild(enemyId, "[CITYWAR] A guild  ".. guild:getName() .." enviou um convite de guerra para a sua guild na cidade ".. commandParam[2] .." do citywar! Para aceitar o líder da guild deve usar o comando para aceitar digite: !citywar accept")
		Game.broadcastMessage("A guild ".. guild:getName() .." declarou guerra contra a guild ".. commandParam[9] .." com limites de ".. commandParam[3] .." frags e ".. commandParam[7] .." jogadores participantes na cidade de ".. commandParam[2] .." no citywar. Os participantes poderão usar a cidade durante 2 horas.", MESSAGE_STATUS_WARNING)
		warBroadcastGuild(enemyId, "[CITYWAR] Informações de Guerra: Guild ".. guild:getName() ..", Cidade ".. commandParam[2] ..", frags ".. commandParam[3] ..", Mágias em área ".. commandParam[4] ..", runas em área ".. commandParam[5] ..", SSA ou Might Ring ".. commandParam[6] ..", ".. commandParam[7] .." jogadores por guild.")

	elseif commandParam[1] == "accept" then

			if commandParam[2] then
				getStorageEntry = seachGuildInStorages(getGuildId(commandParam[2]), getPlayerGuildId(cid))
			end
			if getPlayerGuildLevel(cid) < 3 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas leaders podem usar o comando.")
			elseif not commandParam[2] or commandParam[2] == "" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o segundo parÃ¢metro, selecione alianÃ§a que convidou vocÃª.")
			elseif not getGuildId(commandParam[2]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa guild nÃ£o existe ou o nome estÃ¡ invÃ¡lido.")
			elseif getGuildId(commandParam[2]) == getPlayerGuildId(cid) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] NÃ£o Ã© possÃ­vel aceitar uma chamada guerra do seu prÃ³prio clÃ£.")
			elseif getGlobalStorageValue(WarConfigs["WarSecondGuildID"][getStorageEntry]) ~= getPlayerGuildId(cid) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] NÃ£o hÃ¡ convite ".. commandParam[2] .." para lutar com a sua alianÃ§a.")
			elseif getGlobalStorageValue(WarConfigs["WarAcceptTimeArena"][getStorageEntry]) < os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] O tempo para aceitar o convite guerra expirou.")
			else
				doInitWar(getStorageEntry)
			end
	
	elseif commandParam[1] == "cancel" then

			local GetGuildAndEntryID = checkActiveWarInGuildAndEntryID(getPlayerGuildId(cid))
			if getPlayerGuildLevel(cid) < 3 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas os lÃ­deres da guilda pode usar este comando.")
			elseif not GetGuildAndEntryID then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua Guild nÃ£o estÃ¡ na guerra para executar este comando.")
			elseif getPlayerStorageValue(cid, WarConfigs.WarPlayerJoined) ~= 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Somente lÃ­deres ativos na guerra pode executar um cancelamento.")
			elseif getGlobalStorageValue(WarConfigs["WarArenaStorage"][GetGuildAndEntryID[1]]) < WarConfigs.WarWaitTimeToCancel + os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] O cancelamento de tempo Ã© maior do que o tempo restante para acabar com a guerra, aguarde o fim da guerra.")
			elseif getGlobalStorageValue(WarConfigs["WarCanceledCity"][GetGuildAndEntryID[1]]) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] JÃ¡ hÃ¡ um cancelamento em andamento nesta guerra.")
			else
				executeCancelWarCity(getPlayerNameByGUID(getPlayerGUID(cid)), GetGuildAndEntryID[1], true)
			end
	
	elseif commandParam[1] == "go" then
	
			local GetGuildAndEntryID = checkActiveWarInGuildAndEntryID(getPlayerGuildId(cid))
			if not getTilePzInfo(getThingPos(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] VocÃª sÃ³ pode usar esse comando em Ã¡rea protegida.")
			elseif not GetGuildAndEntryID then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua guild nÃ£o estÃ¡ em guerra.")
			elseif getPlayerStorageValue(cid, WarConfigs.WarPlayerJoined) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] VocÃª jÃ¡ estÃ¡ lutando na guerra.")
			elseif getPlayerSlotItem(cid, CONST_SLOT_RING).itemid == 2164 and getGlobalStorageValue(WarConfigs["WarDontSSAMight"][GetGuildAndEntryID[1]]) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Remova seu might ring primeiro antes de entrar.")
			elseif getPlayerSlotItem(cid, CONST_SLOT_NECKLACE).itemid == 2197 and getGlobalStorageValue(WarConfigs["WarDontSSAMight"][GetGuildAndEntryID[1]]) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Remova seu stone skin amulet primeiro antes de entrar.")
			else
				executeEnterArena(cid, GetGuildAndEntryID[2], GetGuildAndEntryID[1])
			end
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira primeiro os comandos corretamente, invite, accept ou go.")
		end
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Parâmetros insuficientes. Comandos da citywar:" .. "\n"
			.. "!citywar invite" .. "\n"
			.. "!citywar accept" .. "\n"
			.. "!citywar cancel" .. "\n"
			.. "!citywar go")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
	end

	return false
end

citywar_talkaction:separator(" ")
citywar_talkaction:register()
