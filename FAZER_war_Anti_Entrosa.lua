local exhausted = 5 -- Segundos

function onSay(player, words, param)

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

	if commandParam[1] == "invite" then

		local resultId = db.storeQuery('SELECT `name`, `balance` FROM `guilds` WHERE `id` = ' .. guildId)
		if not resultId then
			return false
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Current balance of guild ' .. result.getString(resultId, "name") .. ' is: ' .. result.getNumber(resultId, "balance") .. ' golds coins.')
		result.free(resultId)
		return false
	end

	if player:getLevel() < WarConfigs.WarMinLevel then
		player:say("[CITY WAR] Para participar do citywar é necessário level ".. WarConfigs.WarMinLevel .." ou superior.", TALKTYPE_ORANGE_1)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	-- /citywar invite, city, frags, UE, RUNES AREA, SSA/Might, playersMax, Frontline, GuildContra
	-- /citywar invite, Carlin, 50, desativado, disabled, disabled, 50, disabled, GuildContra
	if commandParam[1] == "invite" then

		if commandParam[2] then #########################
			GetStorageCaseID = table.find(WarConfigs.WarCitys, string.lower(commandParam[2])) #########################
		end #########################
	
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

		if not table.contains(WarConfigs.WarCitys, commandParam[2]) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] A cidade que você escolheu é inválida. As cidades da disponíveis na citywar são ".. table.concat(WarConfigs.WarCitys, ', ') ..".")
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
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Quinto parâmetro de invite insuficiente. Você não especificou se estará ativado o uso de stone skin amulets e stealth rings no citywar.")
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

		local enemy = getEnemyId(commandParam[9])
		if not enemy then
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

		local enemyName = getEnemyName(enemy)
		local guildName = guild:getName()

		if enemy == guildId or enemyName == guildName then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[CITY WAR] Oitavo parâmetro de invite inválido. Você não pode invitar sua própria guilda para a guerra no citywar.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if guild:getMembersOnline() < WarConfigs.WarMinPlayersInGuild then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, sua guild deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if enemy:getMembersOnline() < WarConfigs.WarMinPlayersInGuild then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[CITY WAR] Para invitar uma guerra no citywar, a guild invitada deve ter o mínimo de ".. WarConfigs.WarMinPlayersInGuild .." membros online.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	
			--elseif getHavePlayersInGuildByGuildID(getPlayerGuildId(cid)) < WarConfigs.WarMinPlayersInGuild then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Para convidar qualquerum de sua alianÃ§a deve ter o mÃ­nimo de ".. WarConfigs.WarMinPlayersInGuild .." membros.")
			
			--elseif getHavePlayersInGuildByGuildID(getGuildId(commandParam[9])) < WarConfigs.WarMinPlayersInGuild then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] A alianÃ§a estÃ¡ convidando vocÃª para uma guerra nÃ£o tem o mÃ­nimo de ".. WarConfigs.WarMinPlayersInGuild .." jogadores para iniciar a guerra.")
			
			--elseif not checkWarCitysIps(getPlayerGuildId(cid)) then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua alianÃ§a nÃ£o cumpre os requisitos daf ".. WarConfigs.WarNeedDiferentIps .." diferente IPS.")
			
			--elseif not checkWarCitysIps(getPlayerGuildId(cid)) then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] A guilda que vocÃª convidou-o a guerra nÃ£o estÃ¡ em conformidade com os requisitos da ".. WarConfigs.WarNeedDiferentIps .." IPs diferentes para comeÃ§ar uma guerra.")

		function checkActiveInviteInGuild(GuildID)
			for i = 1, #WarConfigs["WarAcceptTimeArena"] do
				if getGlobalStorageValue(WarConfigs["WarAcceptTimeArena"][i]) > os.time() then
					if getGlobalStorageValue(WarConfigs["WarFirstGuildID"][i]) == GuildID then
						return true
					end
				end
			end
			return false
		end
			
			--elseif checkActiveWarInGuild(getPlayerGuildId(cid)) then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua guild jÃ¡ estÃ¡ em guerra.")
			
			--elseif checkActiveWarInGuild(getGuildId(commandParam[9])) then
				--player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa Guild ".. commandParam[9] .." jÃ¡ estÃ¡ em guerra.")
	

	
			--elseif checkActiveInviteInGuild(getPlayerGuildId(cid)) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Sua alianÃ§a jÃ¡ tem um convite na ativa, esperar convite ou aguardar acabamento.")
			
			elseif checkActiveInviteInGuild(getGuildId(commandParam[9])) then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Essa guild ".. commandParam[9] .." jÃ¡ tem um convite ativo, aguarde.")
			
			Game.getStorageValue(key)
			elseif getGlobalStorageValue(WarConfigs["WarAcceptTimeArena"][GetStorageCaseID]) > os.time() then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] HÃ¡ uma chamada em andamento para a arena, aguarde a chamada terminar se o convite for aceito aguarde atÃ© o fim da guerra.")
			
			Game.getStorageValue(key)
			elseif getGlobalStorageValue(WarConfigs["WarArenaStorage"][GetStorageCaseID]) > 0 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Arena jÃ¡ estÃ¡ em uso, espere terminar a guerra.")
			
			elseif #getOnlineGuildMembers(getGuildId(commandParam[9]), {3}) == 0 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"[War Anti Entrosa] Nenhum dos lÃ­deres da alianÃ§a convidado estÃ¡ online.")
			
			else
				warSetOptions(GetStorageCaseID, 0, os.time() + WarConfigs.WarAcceptTime, commandParam[3], commandParam[4], commandParam[5], commandParam[6], commandParam[7], commandParam[8], getPlayerGuildId(cid), getGuildId(commandParam[9]))
				warBroadcastGuild(getPlayerGuildId(cid), MESSAGE_EVENT_ADVANCE, "O lÃ­der da guilda convidou a guild, ".. commandParam[9] .." para uma guerra em ".. commandParam[2] .."!", {3})
				warBroadcastGuild(getGuildId(commandParam[9]), MESSAGE_EVENT_ADVANCE, "".. getCreatureName(cid) .." da guild ".. getPlayerGuildName(cid) .." convidou sua guild para uma guerra em ".. commandParam[2] ..", para aceitar digite, !citywar accept ou /citywar accept, ".. getPlayerGuildName(cid) .."", {3})
                
				Game.broadcastMessage("", MESSAGE_STATUS_WARNING)
				
				doBroadcastMessage(getPlayerGuildName(cid) .. " Declarou guerra contra guild ".. commandParam[9] .." para ".. commandParam[3] .." mortes e ".. commandParam[7] .." VS ".. commandParam[7] ..", em ".. commandParam[2] .." no sistema WAR ANTI ENTROSA. O leader da guild rival recebeu informaÃ§Ãµes no Local Chat e Server Log sobre a guerra.", 19)
				warBroadcastGuild(getGuildId(commandParam[9]), MESSAGE_STATUS_CONSOLE_BLUE, "OpÃ§Ã£o de Guerra: Cidade ".. commandParam[2] ..", frags ".. commandParam[3] ..", MÃ¡gias em Ã¡rea ".. commandParam[4] ..", Runas em Ã¡rea ".. commandParam[5] ..", DontSSAMight ".. commandParam[6] ..", ".. commandParam[7] .." jogadores por Guild.", {3})
			end
		elseif string.lower(commandParam[1]) == "accept" then
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
		elseif string.lower(commandParam[1]) == "cancel" then
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
		elseif string.lower(commandParam[1]) == "go" then
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
	end
	return true
end
