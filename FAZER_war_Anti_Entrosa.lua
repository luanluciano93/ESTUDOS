local exhausted = 5 -- Segundos

function onSay(player, words, param)

	local exhaustion = player:getExhaustion(Storage.exhaustion.talkaction)
	if exhaustion > 0 then
		player:sendCancelMessage("You're exhausted.")
		-- doCreatureSay(cid,"[War Anti Entrosa] Você só pode usar este comando novamente após ".. exhaustion.get(cid, 211) .." segundos.", TALKTYPE_ORANGE_1)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(5, Storage.exhaustion.talkaction)

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildId = guild:getId()
	if not guildId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local commandParam = param:splitTrimmed(",")
	if not commandParam[1] then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Insufficient parameters. City War commands:" .. "\n"
			.. "!citywar invite" .. "\n"
			.. "!citywar accept" .. "\n"
			.. "!citywar cancel" .. "\n"
			.. "!citywar go")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if not table.contains({"invite", "accept", "cancel", "go"}, commandParam[1]) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] Invalid parameters. Guild War commands:" .. "\n"
			.. "!citywar invite" .. "\n"
			.. "!citywar accept" .. "\n"
			.. "!citywar cancel" .. "\n"
			.. "!citywar go")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if player:getGuildLevel() < 3 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] You need to be the guild leader to execute this command.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if commandParam[1] == "invite" then

		local resultId = db.storeQuery('SELECT `name`, `balance` FROM `guilds` WHERE `id` = ' .. guildId)
		if not resultId then
			return false
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Current balance of guild ' .. result.getString(resultId, "name") .. ' is: ' .. result.getNumber(resultId, "balance") .. ' golds coins.')
		result.free(resultId)
		return false
	end


	
	else
		-- /citywar invite, city, frags, UE, RUNES AREA, SSA/Might, playersMax, Frontline, GuildContra
		-- /citywar invite, Carlin, 50, disabled, disabled, disabled, 50, disabled, GuildContra
		if string.lower(commandParam[1]) == "invite" then
			if commandParam[2] then
				GetStorageCaseID = table.find(WarConfigs.WarCitys, string.lower(commandParam[2]))
			end
			if getPlayerGuildLevel(cid) < 3 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas leaders da guild podem usar o comando.")
			
			elseif player:getLevel() < WarConfigs.WarGuildLeaderMinLevel then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas leaders de Guilds com level ".. WarConfigs.WarGuildLeaderMinLevel .." ou mais pode usar este comando.")
			
			elseif not commandParam[2] or commandParam[2] == "" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o segundo parâmetros, selecione cidade.")
			
			elseif not table.contains(WarConfigs.WarCitys, commandParam[2]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Seleciona uma cidade válida, para mais informações acesse nosso site..")
				doPlayerPopupFYI(cid,"[War Anti Entrosa] Cidades disponíveis para a guerra:\n\n".. table.concat(WarConfigs.WarCitys, ', ') ..".")
			
			elseif not commandParam[3] or commandParam[3] == "" or not tonumber(commandParam[3]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o terceiro parâmetro, selecione quantidade frags para terminar a guerra, insira apenas números.")
			
			elseif not commandParam[4] or commandParam[4] == "" or string.lower(commandParam[4]) ~= "enabled" and string.lower(commandParam[4]) ~= "disabled" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o quarto parâmetro, select if ultimate explosion, enabled or disabled.")
			
			elseif not commandParam[5] or commandParam[5] == "" or string.lower(commandParam[5]) ~= "enabled" and string.lower(commandParam[5]) ~= "disabled" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o quinto parâmetro, select if area runes, enabled or disabled.")
			
			elseif not commandParam[6] or commandParam[6] == "" or string.lower(commandParam[6]) ~= "enabled" and string.lower(commandParam[6]) ~= "disabled" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o sexto parâmetro, select whether the amulet block stone skin and stealth ring, enabled or disabled.")
			
			elseif not commandParam[7] or commandParam[7] == "" or not tonumber(commandParam[7]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o setimo parâmetro, selecione limite de jogadores para cada aliança, insira apenas números.")
			
			elseif tonumber(commandParam[7]) < WarConfigs.WarMinPlayers then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Minímo de jogadores necessário em cada Guild ".. WarConfigs.WarMinPlayers ..".")
			
			elseif not commandParam[8] or commandParam[8] == "" or string.lower(commandParam[8]) ~= "enabled" and string.lower(commandParam[8]) ~= "disabled" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o oitavo parâmetro, se quer limitar ou nao o numero de front lines na guerra.")				
			
			elseif not commandParam[9] or commandParam[9] == "" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o nono parâmetro, selecione o nome de alianças que você quer a guerra.")
			
			
			local enemy = getEnemyId(commandParam[9])
			if not enemy then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Guild '.. commandParam[9] ..' does not exists.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local enemyName = getEnemyName(enemy)
			local guildName = guild:getName()

			if enemy == guildId then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You cannot perform war action on your own guild.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
					
			
			
			elseif not getGuildId(commandParam[9]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] A guild com esse nome não existe.")
			
			elseif getGuildId(commandParam[9]) == getPlayerGuildId(cid) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Você não pode chamar sua própria aliança a guerra.")
			
			guild:getMembersOnline()
			enemy:getMembersOnline()
			
			elseif getHavePlayersInGuildByGuildID(getPlayerGuildId(cid)) < WarConfigs.WarMinPlayersInGuild then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Para convidar qualquerum de sua aliança deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros.")
			
			elseif getHavePlayersInGuildByGuildID(getGuildId(commandParam[9])) < WarConfigs.WarMinPlayersInGuild then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] A aliança está convidando você para uma guerra não tem o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." jogadores para iniciar a guerra.")
			
			elseif not checkWarCitysIps(getPlayerGuildId(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua aliança não cumpre os requisitos daf ".. WarConfigs.WarNeedDiferentIps .." diferente IPS.")
			
			elseif not checkWarCitysIps(getPlayerGuildId(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] A guilda que você convidou-o a guerra não está em conformidade com os requisitos da ".. WarConfigs.WarNeedDiferentIps .." IPs diferentes para começar uma guerra.")
			
			elseif checkActiveWarInGuild(getPlayerGuildId(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua guild já está em guerra.")
			
			elseif checkActiveWarInGuild(getGuildId(commandParam[9])) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa Guild ".. commandParam[9] .." já está em guerra.")
			
			elseif checkActiveInviteInGuild(getPlayerGuildId(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua aliança já tem um convite na ativa, esperar convite ou aguardar acabamento.")
			
			elseif checkActiveInviteInGuild(getGuildId(commandParam[9])) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa guild ".. commandParam[9] .." já tem um convite ativo, aguarde.")
			
			Game.getStorageValue(key)
			elseif getGlobalStorageValue(WarConfigs["WarAcceptTimeArena"][GetStorageCaseID]) > os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Há uma chamada em andamento para a arena, aguarde a chamada terminar se o convite for aceito aguarde até o fim da guerra.")
			
			Game.getStorageValue(key)
			elseif getGlobalStorageValue(WarConfigs["WarArenaStorage"][GetStorageCaseID]) > 0 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Arena já está em uso, espere terminar a guerra.")
			
			elseif #getOnlineGuildMembers(getGuildId(commandParam[9]), {3}) == 0 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Nenhum dos líderes da aliança convidado está online.")
			
			else
				warSetOptions(GetStorageCaseID, 0, os.time() + WarConfigs.WarAcceptTime, commandParam[3], commandParam[4], commandParam[5], commandParam[6], commandParam[7], commandParam[8], getPlayerGuildId(cid), getGuildId(commandParam[9]))
				warBroadcastGuild(getPlayerGuildId(cid), MESSAGE_EVENT_ADVANCE, "O líder da guilda convidou a guild, ".. commandParam[9] .." para uma guerra em ".. commandParam[2] .."!", {3})
				warBroadcastGuild(getGuildId(commandParam[9]), MESSAGE_EVENT_ADVANCE, "".. getCreatureName(cid) .." da guild ".. getPlayerGuildName(cid) .." convidou sua guild para uma guerra em ".. commandParam[2] ..", para aceitar digite, !citywar accept ou /citywar accept, ".. getPlayerGuildName(cid) .."", {3})
                
				Game.broadcastMessage("", MESSAGE_STATUS_WARNING)
				
				doBroadcastMessage(getPlayerGuildName(cid) .. " Declarou guerra contra guild ".. commandParam[9] .." para ".. commandParam[3] .." mortes e ".. commandParam[7] .." VS ".. commandParam[7] ..", em ".. commandParam[2] .." no sistema WAR ANTI ENTROSA. O leader da guild rival recebeu informações no Local Chat e Server Log sobre a guerra.", 19)
				warBroadcastGuild(getGuildId(commandParam[9]), MESSAGE_STATUS_CONSOLE_BLUE, "Opção de Guerra: Cidade ".. commandParam[2] ..", frags ".. commandParam[3] ..", Mágias em área ".. commandParam[4] ..", Runas em área ".. commandParam[5] ..", DontSSAMight ".. commandParam[6] ..", ".. commandParam[7] .." jogadores por Guild.", {3})
			end
		elseif string.lower(commandParam[1]) == "accept" then
			if commandParam[2] then
				getStorageEntry = seachGuildInStorages(getGuildId(commandParam[2]), getPlayerGuildId(cid))
			end
			if getPlayerGuildLevel(cid) < 3 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas leaders podem usar o comando.")
			elseif not commandParam[2] or commandParam[2] == "" then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Insira o segundo parâmetro, selecione aliança que convidou você.")
			elseif not getGuildId(commandParam[2]) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa guild não existe ou o nome está inválido.")
			elseif getGuildId(commandParam[2]) == getPlayerGuildId(cid) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Não é possível aceitar uma chamada guerra do seu próprio clã.")
			elseif getGlobalStorageValue(WarConfigs["WarSecondGuildID"][getStorageEntry]) ~= getPlayerGuildId(cid) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Não há convite ".. commandParam[2] .." para lutar com a sua aliança.")
			elseif getGlobalStorageValue(WarConfigs["WarAcceptTimeArena"][getStorageEntry]) < os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] O tempo para aceitar o convite guerra expirou.")
			else
				doInitWar(getStorageEntry)
			end
		elseif string.lower(commandParam[1]) == "cancel" then
			local GetGuildAndEntryID = checkActiveWarInGuildAndEntryID(getPlayerGuildId(cid))
			if getPlayerGuildLevel(cid) < 3 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Apenas os líderes da guilda pode usar este comando.")
			elseif not GetGuildAndEntryID then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua Guild não está na guerra para executar este comando.")
			elseif getPlayerStorageValue(cid, WarConfigs.WarPlayerJoined) ~= 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Somente líderes ativos na guerra pode executar um cancelamento.")
			elseif getGlobalStorageValue(WarConfigs["WarArenaStorage"][GetGuildAndEntryID[1]]) < WarConfigs.WarWaitTimeToCancel + os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] O cancelamento de tempo é maior do que o tempo restante para acabar com a guerra, aguarde o fim da guerra.")
			elseif getGlobalStorageValue(WarConfigs["WarCanceledCity"][GetGuildAndEntryID[1]]) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Já há um cancelamento em andamento nesta guerra.")
			else
				executeCancelWarCity(getPlayerNameByGUID(getPlayerGUID(cid)), GetGuildAndEntryID[1], true)
			end
		elseif string.lower(commandParam[1]) == "go" then
			local GetGuildAndEntryID = checkActiveWarInGuildAndEntryID(getPlayerGuildId(cid))
			if not getTilePzInfo(getThingPos(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Você só pode usar esse comando em área protegida.")
			elseif not GetGuildAndEntryID then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua guild não está em guerra.")
			elseif getPlayerStorageValue(cid, WarConfigs.WarPlayerJoined) == 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Você já está lutando na guerra.")
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
	end
	return true
end
