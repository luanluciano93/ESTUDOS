-- Revscript City War by luanluciano93 --

-- !citywar invite, city, frags, UE, RUNES AREA, SSA/Might, playersMax, Frontline, guildEnemy   / ex: !citywar invite, Carlin, 50, desativado, disabled, disabled, 50, disabled, Wicked
-- !citywar accept, guildEnemy                                                                  / ex: !citywar accept, Wicked
-- !citywar cancel, guildEnemy                                                                  / ex: !citywar cancel, Wicked
-- !citywar go                                                                                  / ex: !citywar go

WarConfigs =
{

	WarLossExpPercent = 10,
	WarLossSkillsPercent = 0,

	-- Global Storages
	["WarFirstTeamPlayerCount"] = {77050, 77051, 77052, 77053, 77054, 77055, 77056, 77057},
	["WarSecondTeamPlayerCount"] = {78060, 78061, 78062, 78063, 78064, 78065, 78066, 78067},

	["WarFirstTeamPlayerDeathsCount"] = {82100, 82101, 82102, 82103, 82104, 82105, 82106, 82107},
	["WarSecondTeamPlayerDeathsCount"] = {83110, 83111, 83112, 83113, 83114, 83115, 83116, 83117},

	["WarMinutesInactive"] = {84120, 84121, 84122, 84123, 84124, 84125, 84126, 84127},
	["WarTeamInactive"] = {85130, 85131, 85132, 85133, 85134, 85135, 85136, 85137},

	["WarCanceledCity"] = {86140, 86141, 86142, 86143, 86144, 86145, 86146, 86147},

	["WarFirstTeamFrontCount"] = {745040, 745041, 745042, 745043, 745044, 745045, 745046, 745047},
	["WarSecondTeamFrontCount"] = {755040, 755041, 755042, 755043, 755044, 755045, 755046, 755047},
	
	-- Players Storages
	WarUrgentExit = 73002,

	WarFrontLine = 732020
}


local config = {

	warCitys = {"dust2", "darashia", "roshamuul", "carlin", "thais", "edron"},

	warGuildPosition = {
		Position(3594, 3251, 6), -- Dust2
		Position(3594, 3251, 6), -- Darashia
		Position(3594, 3251, 6), -- Roshamuul
		Position(3594, 3251, 6) -- Carlin
		Position(3594, 3251, 6), -- Thais
		Position(3594, 3251, 6) -- Edron
	},
	
	warEnemyPosition = {
		Position(3594, 3251, 6), -- Dust2
		Position(3594, 3251, 6), -- Darashia
		Position(3594, 3251, 6), -- Roshamuul
		Position(3594, 3251, 6) -- Carlin
		Position(3594, 3251, 6), -- Thais
		Position(3594, 3251, 6) -- Edron
	},


	WarMinLevel = 250,
	WarMaxFrontLine = 4,
	WarMinPlayersInGuild = 1,

	warAcceptInviteTime = 5 * 60,
	warTotalLimitTime = 2 * 60 * 60,
	warWaitTimeToCancel = 1 * 60,


	globalStorage_warInviteTime = {1000, 1001},
	globalStorage_warInviteGuild = {1100, 1101},
	globalStorage_warInviteEnemy = {1200, 1201},

	globalStorage_warActiveTime = {1300, 1301},
	globalStorage_warAtiveGuild = {1400, 1401},
	globalStorage_warAtiveEnemy = {1500, 1501},
	
	globalStorage_warDeathsCountGuild = {1500, 1501},
	globalStorage_warDeathsCountEnemy = {1500, 1501},

	globalStorage_warEnterPlayersGuild = {1500, 1501},
	globalStorage_warEnterPlayersEnemy = {1500, 1501},

	globalStorage_warFrontlineCountGuild = {1500, 1501},
	globalStorage_warFrontlineCountEnemy = {1500, 1501},
	
	globalStorage_warLimiteFrags = {1600, 1601},
	globalStorage_warLimitePlayers = {2000, 2001},
	globalStorage_warLimiteFrontline = {2100, 2101},

	globalStorage_warMagiasArea = {1700, 1701},
	globalStorage_warRunasArea = {1800, 1801},
	globalStorage_warItensReducao = {1900, 1901},
	
	globalStorage_warCancelada = {2200, 2201},
	
	storageWarPlayerJoined = 73000,
	storageWarUEDisabled = 73003,
	storageWarAreaRunesDisabled = 73004,
	storageWarSSAMight = 732015,
}

local citys = {
	["carlin"] = 1,
	["edron"] = 2,
},

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

function citywar_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(config.storageWarPlayerJoined, 0)
		player:setStorageValue(config.storageWarUEDisabled, 0)
		player:setStorageValue(config.storageWarAreaRunesDisabled, 0)
		player:setStorageValue(config.storageWarSSAMight, 0)
	end
end

local function executeFinishWar(warId, timeActive)
	if Game.getStorageValue(config.globalStorage_warActiveTime[id]) == timeActive then
		for _, player in ipairs(Game.getPlayers()) do
			if player then
				if player:getStorageValue(config.storageWarPlayerJoined) == warId then
					citywar_removePlayer(player:getGuid())
				end
			end
		end

		local msg = ""
		local guildDeaths = Game.getStorageValue(config.globalStorage_warDeathsCountGuild[warId])
		local enemyDeaths = Game.getStorageValue(config.globalStorage_warDeathsCountEnemy[warId])
		local guildOne = Guild(Game.getStorageValue(config.globalStorage_warAtiveGuild[warId]))
		local guildTwo = Guild(Game.getStorageValue(config.globalStorage_warAtiveEnemy[warId]))

		if not guildWin or not guildLose then
			return print("[CITY WAR] Erro de guild inválidas. Id 1: ".. Game.getStorageValue(config.globalStorage_warAtiveGuild[warId]) .." e ID 2: ".. Game.getStorageValue(config.globalStorage_warAtiveEnemy[warId]) ..".")
		end

		if guildKills < enemyKills then
			msg = "[CITY WAR] A guild ".. guildOne:getName() .." venceu a guild ".. guildTwo:getName() .." por ".. enemyDeaths .." x ".. guildDeaths .." no citywar!"
		elseif guildDeaths > enemyDeaths then
			msg = "[CITY WAR] A guild ".. guildTwo:getName() .." venceu a guild ".. guildOne:getName() .." por ".. guildDeaths .." x ".. enemyDeaths .." no citywar!"
		else
			msg = "[CITY WAR] A guild ".. guildOne:getName() .." empatou com a guild ".. guildTwo:getName() .." por ".. enemyDeaths .." x ".. guildDeaths .." no citywar!"
		end

		broadcastMessage(msg, MESSAGE_STATUS_WARNING)
		print(msg)

		Game.setStorageValue(config.globalStorage_warInviteTime[warId], 0)
		Game.setStorageValue(config.globalStorage_warInviteGuild[warId], 0)
		Game.setStorageValue(config.globalStorage_warInviteEnemy[warId], 0)
		Game.setStorageValue(config.globalStorage_warActiveTime[warId], 0)
		Game.setStorageValue(config.globalStorage_warAtiveGuild[warId], 0)
		Game.setStorageValue(config.globalStorage_warAtiveEnemy[warId], 0)
		Game.setStorageValue(config.globalStorage_warDeathsCountGuild[warId], 0)
		Game.setStorageValue(config.globalStorage_warDeathsCountEnemy[warId], 0)
		Game.setStorageValue(config.globalStorage_warLimiteFrags[warId], 0)
		Game.setStorageValue(config.globalStorage_warMagiasArea[warId], 0)
		Game.setStorageValue(config.globalStorage_warRunasArea[warId], 0)
		Game.setStorageValue(config.globalStorage_warItensReducao[warId], 0)
		Game.setStorageValue(config.globalStorage_warLimitePlayers[warId], 0)
		Game.setStorageValue(config.globalStorage_warLimiteFrontline[warId], 0)
		Game.setStorageValue(config.globalStorage_warCancelada[warId], 0)
	end
end

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

	local function getEnemyId(enemyName)
		local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `name` = " .. db.escapeString(enemyName))
		if resultId == false then
			return false
		end

		local enemyId = result.getNumber(resultId, "id")
		result.free(resultId)
		return enemyId
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

		if checkGlobalStorages(config.globalStorage_warInviteGuild, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild já invitou uma guerra no citywar. Se não quiser aguarda-lá, cancele-a.")
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
		
		Game.setStorageValue(config.config.globalStorage_warInviteGuild[city], guildId)
		Game.setStorageValue(config.config.globalStorage_warInviteEnemy[city], enemyId)		

		if warBroadcastGuild(guildId, "[CITYWAR] O líder da guild convidou a guild ".. commandParam[9] .." para uma guerra em na cidade ".. commandParam[2] .." do citywar!") then
			if warBroadcastGuild(enemyId, "[CITYWAR] A guild  ".. guild:getName() .." enviou um convite de guerra para a sua guild na cidade ".. commandParam[2] .." do citywar! Para aceitar o líder da guild deve usar o comando para aceitar digite: !citywar accept") then
				if warBroadcastGuild(enemyId, "[CITYWAR] Informações de Guerra: Guild ".. guild:getName() ..", Cidade ".. commandParam[2] ..", frags ".. commandParam[3] ..", Mágias em área ".. commandParam[4] ..", runas em área ".. commandParam[5] ..", SSA ou Might Ring ".. commandParam[6] ..", ".. commandParam[7] .." jogadores por guild.") then
					Game.broadcastMessage("A guild ".. guild:getName() .." declarou guerra contra a guild ".. commandParam[9] .." com limites de ".. commandParam[3] .." frags e ".. commandParam[7] .." jogadores participantes na cidade de ".. commandParam[2] .." no citywar. Os participantes poderão usar a cidade durante 2 horas.", MESSAGE_STATUS_WARNING)
				end
			end
		end

		return false
	
	elseif commandParam[1] == "accept" then

		if player:getGuildLevel() < 3 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Você não é líder de uma guild para usar esse comando.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[2] or commandParam[2] == "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Parâmetro de aceitar convite insuficiente. Você não especificou o nome da guild que te enviou o convite.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end	

		local enemyId = getEnemyId(commandParam[2])
		if not enemyId then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Parâmetro de aceitar convite inválido. A guild '.. commandParam[2] ..' não existe.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end		

		if not checkGlobalStorages(config.globalStorage_warInviteGuild, enemyId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A guild ".. commandParam[2] .." não convidou a sua sua guild para a guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not checkGlobalStorages(config.globalStorage_warInviteEnemy, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild não tem nenhum convite pendente no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if checkGlobalStorages(config.globalStorage_warAtiveGuild, guildId) or checkGlobalStorages(config.globalStorage_warAtiveEnemy, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild já está em uma guerra ativa no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if checkGlobalStorages(config.globalStorage_warAtiveGuild, enemyId) or checkGlobalStorages(config.globalStorage_warAtiveEnemy, enemyId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A guild que você quer invitar já está em uma guerra ativa no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function searchGuildInStoragesInviteWar(firstGuildID, secondGuildID)
			for i = 1, #config.globalStorage_warInviteGuild do
				if Game.getStorageValue(config.globalStorage_warInviteGuild[i]) == secondGuildID then
					if Game.getStorageValue(config.globalStorage_warInviteEnemy[i]) == firstGuildID then
						return i
					end
				end
			end
			return false
		end

		local id = searchGuildInStoragesInviteWar(guildId, enemyId)
		if not id then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild não tem convite de guerra da guild ".. commandParam[2] .." no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
			
		if Game.getStorageValue(config.globalStorage_warActiveTime[id]) > os.time()  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A cidade ".. config.warCitys[id] .." do citywar já está em uso. Aguarde sua liberação ou escolha outra cidade.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if Game.getStorageValue(config.globalStorage_warInviteTime[id]) < os.time()  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] O tempo para aceitar o convite de guerra no citywar expirou.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		Game.setStorageValue(config.globalStorage_warActiveTime[id], config.warTotalLimitTime + os.time())
		Game.setStorageValue(config.globalStorage_warAtiveGuild[id], enemyId)
		Game.setStorageValue(config.globalStorage_warAtiveEnemy[id], guildId)

		warBroadcastGuild(guildId,  "[CITY WAR] Sua guild está em guerra no citywar, para participar da guerra digite de um local protection zone: !citywar go")
		warBroadcastGuild(enemyId, "[CITY WAR] Sua Aliança está em guerra no citywar, para participar da guerra digite de um local protection zone: !citywar go")
		addEvent(executeFinishWar, config.warTotalLimitTime * 1000, id, Game.getStorageValue(config.globalStorage_warActiveTime[id]))

		return false

	elseif commandParam[1] == "cancel" then

		if player:getGuildLevel() < 3 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Você não é líder de uma guild para usar esse comando.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not commandParam[2] or commandParam[2] == "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Parâmetro de cancelar guerra insuficiente. Você não especificou o nome da guild que você esta em guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end	

		local enemyId = getEnemyId(commandParam[2])
		if not enemyId then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Parâmetro de cancelar guerra inválido. A guild '.. commandParam[2] ..' não existe.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end		

		if not checkGlobalStorages(config.globalStorage_warAtiveGuild, guildId) and not checkGlobalStorages(config.globalStorage_warAtiveEnemy, guildId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild já está em uma guerra ativa no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not checkGlobalStorages(config.globalStorage_warAtiveGuild, guildId) and not checkGlobalStorages(config.globalStorage_warAtiveEnemy, enemyId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A guild ".. commandParam[2] .." não esta em guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function searchGuildInStoragesActiveWar(firstGuildID, secondGuildID)
			for i = 1, #config.globalStorage_warAtiveGuild do
				if Game.getStorageValue(config.globalStorage_warAtiveGuild[i]) == firstGuildID then
					if Game.getStorageValue(config.globalStorage_warAtiveEnemy[i]) == secondGuildID then
						return i
					end

				elseif Game.getStorageValue(config.globalStorage_warAtiveEnemy[i]) == firstGuildID then
					if Game.getStorageValue(config.globalStorage_warAtiveGuild[i]) == secondGuildID then
						return i
					end
				end
			end
			return false
		end	

		local id = searchGuildInStoragesActiveWar(guildId, enemyId)
		if not id then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild não esta em guerra com a guild ".. commandParam[2] .." no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
			
		if Game.getStorageValue(config.globalStorage_warActiveTime[id]) > os.time()  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A cidade ".. config.warCitys[id] .." do citywar já está em uso. Aguarde sua liberação ou escolha outra cidade.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if player:getStorageValue(config.storageWarPlayerJoined) < 1 then	
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Somente líderes ativos na guerra podem executar um cancelamento de guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if Game.getStorageValue(config.globalStorage_warActiveTime[id]) < os.time() + config.warWaitTimeToCancel then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] O tempo do cancelamento é maior do que o tempo restante para acabar com a guerra, aguarde o fim da guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if Game.getStorageValue(config.globalStorage_warCancelada[id]) == 1 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guerra do citywar já está em processo de cancelamento, aguarde por gentileza.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		Game.setStorageValue(config.globalStorage_warCancelada[id]), 1)

		if warBroadcastGuild(guildId, MESSAGE_EVENT_ADVANCE, "[CITY WAR] A guerra no citywar foi cancelada por ".. player:getName() ..", e será encerrada em ".. config.warWaitTimeToCancel .." minutos.") and warBroadcastGuild(enemyId, MESSAGE_EVENT_ADVANCE, "[CITY WAR] A guerra no citywar foi cancelada por ".. player:getName() ..", e será encerrada em ".. config.warWaitTimeToCancel .." minutos.") then
			addEvent(executeFinishWar, config.warWaitTimeToCancel * 1000, id, Game.getStorageValue(config.globalStorage_warActiveTime[id]))
		end

		return false
	
	elseif commandParam[1] == "go" then

		local tile = Tile(player:getPosition())
		if not tile then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'Invalid tile position.')
			return false
		end

		if not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Você só pode usar este comando em um tile protection zone.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if player:getStorageValue(config.storageWarPlayerJoined) > 0 then	
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você já está dentro de uma guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function searchGuildInActiveWar(warGuild)
			for i = 1, #config.globalStorage_warAtiveGuild do
				if Game.getStorageValue(config.globalStorage_warAtiveGuild[i]) == warGuild then
					return i
				
				elseif Game.getStorageValue(config.globalStorage_warAtiveEnemy[i]) == warGuild then
					return i
				end
			end
			return false
		end		

		local id = searchGuildInActiveWar(guildId)
		if not id then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild não esta em guerra no citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local might_ring = 2164
		if player:getItemCount(might_ring) > 0 and Game.getStorageValue(config.globalStorage_warItensReducao[id]) == 1 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você não pode entrar no citywar com ".. ItemType(might_ring):getName() ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local stone_skin_amulet = 2197
		if player:getItemCount(stone_skin_amulet) > 0 and Game.getStorageValue(config.globalStorage_warItensReducao[id]) == 1 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Você não pode entrar no citywar com ".. ItemType(stone_skin_amulet):getName() ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function checkToEnterWarArena(warIdCheck, guildIdCheck)
			if Game.getStorageValue(config.globalStorage_warAtiveGuild[warIdCheck]) == guildIdCheck then
				if Game.getStorageValue(config.globalStorage_warEnterPlayersGuild[warIdCheck]) < Game.getStorageValue(config.globalStorage_warLimitePlayers[warIdCheck]) then
					return 1
				else
					return false
				end
			elseif Game.getStorageValue(config.globalStorage_warAtiveEnemy[warIdCheck]) == guildIdCheck then
				if Game.getStorageValue(config.globalStorage_warEnterPlayersEnemy[warIdCheck]) < Game.getStorageValue(config.globalStorage_warLimitePlayers[warIdCheck]) then
					return 2
				else
					return false
				end
			else
				return false
			end
		end

		local team = checkToEnterWarArena(id, guildId)
		if not team then				
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild está com o limite máximo de ".. Game.getStorageValue(config.globalStorage_warLimitePlayers[id]) .." jogadores dentro da citywar.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function checkToEnterWarArenaFrontline(warIdCheckFrontline, guildIdCheckFrontline)
			if Game.getStorageValue(config.globalStorage_warAtiveGuild[warIdCheckFrontline]) == guildIdCheckFrontline then
				if Game.getStorageValue(config.globalStorage_warFrontlineCountGuild[warIdCheckFrontline]) < Game.getStorageValue(config.globalStorage_warLimiteFrontline[warIdCheckFrontline]) then
					return true
				else
					return false
				end
			elseif Game.getStorageValue(config.globalStorage_warAtiveEnemy[warIdCheckFrontline]) == guildIdCheckFrontline then
				if Game.getStorageValue(config.globalStorage_warFrontlineCountEnemy[warIdCheckFrontline]) < Game.getStorageValue(config.globalStorage_warLimiteFrontline[warIdCheckFrontline]) then
					return true
				else
					return false
				end
			else
				return false
			end
		end

		if table.contains({3, 4, 7, 8}, player:getVocation():getId() and Game.getStorageValue(config.globalStorage_warLimiteFrontline[id]) > 0 then
			if not checkToEnterWarArenaFrontline(id, guildId) then				
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Sua guild está com o limite máximo de ".. Game.getStorageValue(config.globalStorage_warLimiteFrontline[id]) .." jogadores frontlines dentro da citywar.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			
			if team == 1 then
				Game.setStorageValue(config.globalStorage_warFrontlineCountGuild[id], Game.getStorageValue(config.globalStorage_warFrontlineCountGuild[id] + 1)
			elseif team == 2 then
				Game.setStorageValue(config.globalStorage_warFrontlineCountEnemy[id], Game.getStorageValue(config.globalStorage_warFrontlineCountEnemy[id] + 1)
			else
				print("[CITY WAR] Erro na variavel team na verificacao de frontline.")
			end
		end

		if Game.getStorageValue(config.globalStorage_warMagiasArea[id]) == 1 then
			player:setStorageValue(config.storageWarUEDisabled, 1)
		end
		if Game.getStorageValue(config.globalStorage_warRunasArea[id]) == 1 then
			player:setStorageValue(config.storageWarAreaRunesDisabled, 1)
		end
		if Game.getStorageValue(config.globalStorage_warItensReducao[id]) == 1 then
			player:setStorageValue(config.storageWarSSAMight, 1)
		end

		player:setStorageValue(config.storageWarPlayerJoined, id)

		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		if Game.getStorageValue(config.WarConfigs["WarTeamInactive"][id]) == 3 then
			Game.setStorageValue(config.WarConfigs["WarMinutesInactive"][id], 0)
			Game.setStorageValue(config.WarConfigs["WarTeamInactive"][id], 0)
		end
		
		if team == 1 then
			if Game.getStorageValue(config.WarConfigs["WarTeamInactive"][id]) == 1 then
				Game.setStorageValue(config.WarConfigs["WarMinutesInactive"][id], 0)
				Game.setStorageValue(config.WarConfigs["WarTeamInactive"][id], 0)
			end

			Game.setStorageValue(config.globalStorage_warEnterPlayersGuild[id], Game.getStorageValue(config.globalStorage_warEnterPlayersGuild[id]) + 1)
			player:teleportTo(config.warGuildPosition[id])

		else
			if Game.getStorageValue(config.WarConfigs["WarTeamInactive"][id]) == 2 then
				Game.setStorageValue(config.WarConfigs["WarMinutesInactive"][id], 0)
				Game.setStorageValue(config.WarConfigs["WarTeamInactive"][id], 0)
			end
			Game.setStorageValue(config.globalStorage_warEnterPlayersEnemy[id], Game.getStorageValue(config.globalStorage_warEnterPlayersEnemy[id]) + 1)
			player:teleportTo(config.warEnemyPosition[id])
		end

		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[CITY WAR] Você entrou no citywar para defender sua guild, boa sorte.")

		return false

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
