-- player_namelocks # NÃO TESTADO
-- player_spells # NÃO TESTADO

-- guild_wars # AO DELETAR O CHAR, A GUILD É DELETADA PORÉM O GUILD WAR NAO

-- market_history
-- market_offers

-- player_deaths * (deletar os que tiverem mais de 30 dias?


-- <globalevent type="startup" name="CleanDatabase" script="cleanDatabase.lua" />

--[[ 
	Este script realiza limpezas na database toda vez que o servidor é iniciado, com o intuito principal de não sobrecarrega-lá.
	Ele funciona conforme a configuração:
		- Deletando personagens inativos há X meses.
		- Deletando contas que estão vazias (que não tem personagens criados) há X meses.
		- Deixando as casas livres caso o seu dono não entre no jogo por mais de X dias.
		- Deletando os invites de casas feitos por ex-moradores caso a casa não tenha dono.
		- Deletando guilds que foram criadas há X dias e que tem menos de Y membros.
	Crédito: luanluciano93, Leu e Cjaker.
]]--

local inactiveMonthsToDeleteCharacter = 1 -- quantos meses o player precisa ficar inativo para ser deletado.
local emptyAccountMonths = 1 -- quantos meses uma conta precisa ficar sem nenhum character criado para ser deletada.
local inactiveDaysToCleanHouse = 7 -- quantos dias o player precisa ficar inativo para perder a house.
local inactiveDaysToCleanGuildWithFewPlayers = 10 -- quantos dias após a criação da guild irá verificar a quantidade mínima de players.
local minimumGuildMembers = 5 -- quantidade minima de membros para a guild não entrar na verificação.

local function doCheckInactivePlayer() -- deleta automaticamente o dados das tabelas "houses, player_items, player_depotitems, player_deaths, guilds, player_storage"
	local timeStamp = os.time() - (86400 * (inactiveMonthsToDeleteCharacter * 30))
	local totalClear = 0

	local fromClause = "`players` WHERE `group_id` = 1 AND lastlogin <= ".. timeStamp

	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM ".. fromClause)
	if resultId ~= false then
		totalClear = result.getNumber(resultId, 'count')
		result.free(resultId)
		if totalClear > 0 then
			db.query("DELETE FROM ".. fromClause)
		end
	end
	return totalClear
end

local function doCheckEmptyAccounts() -- deleta automaticamente o dados das tabelas  "player_viplist"
	local timeStamp = os.time() - (86400 * (emptyAccountMonths * 30))
	local totalClear = 0

	local fromClause = "`accounts` WHERE `accounts`.`creation` <= ".. timeStamp .." AND NOT EXISTS (SELECT `id` FROM `players` WHERE `accounts`.`id` = `players`.`account_id`)"

	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM ".. fromClause)
	if resultId ~= false then
		totalClear = result.getNumber(resultId, "count")
		result.free(resultId)
		if totalClear > 0 then
			db.query("DELETE FROM ".. fromClause)
		end
	end
	return totalClear
end

local function doCheckInactiveHouses()
	local timeStamp = os.time() - (86400 * (inactiveDaysToCleanHouse * 24))
	local totalClear = 0
	
	local resultId = db.storeQuery("SELECT `houses`.`owner`, `houses`.`id` FROM `houses`, `players` WHERE `houses`.`owner` != 0 AND `houses`.`owner` = `players`.`id` AND `players`.`lastlogin` <= " .. timeStamp .. ";")
	if resultId ~= false then		
		repeat
			local owner = result.getNumber(resultId, "owner")
			local houseId = result.getNumber(resultId, "id")
			local house = House(houseId)

			if house and (owner > 0) then
				house:setOwnerGuid(0)
				totalClear = totalClear + 1
			end
		until not result.next(resultId)
		result.free(resultId)
	end
	return totalClear
end

local function doCheckInactiveHouseLists() -- Apagando "house_lists" do player
	local totalClear = 0

	local fromClause = "`house_lists` WHERE EXISTS EXISTS (SELECT `id` FROM `houses` WHERE `house_lists`.`house_id` = `houses`.`id` AND `houses`.`owner` = 0)"

	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM ".. fromClause)
	if resultId ~= false then
		totalClear = result.getNumber(resultId, "count")
		result.free(resultId)
		if totalClear > 0 then
			db.query("DELETE FROM ".. fromClause)
		end
	end
	return totalClear
end

local function doCheckInactiveGuilds() -- deleta automaticamente o dados das tabelas  "guild_invites, guild_membership, guild_ranks"
	local timeStamp = os.time() - (86400 * (inactiveDaysToCleanGuildWithFewPlayers * 24))
	local totalClear = 0
	
	local fromClause = "`guilds` WHERE `guilds`.`creationdata` <= ".. timeStamp .." AND (SELECT COUNT(*) from `guild_membership` WHERE `guild_membership`.`guild_id` = `guilds`.`id`) < " .. minimumGuildMembers .. ""

	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM ".. fromClause)
	if resultId ~= false then
		totalClear = result.getNumber(resultId, "count")
		result.free(resultId)
		if totalClear > 0 then
			db.query("DELETE FROM ".. fromClause)
		end
	end
	return totalClear
end

-- Executando as funções de limpeza ao iniciar o servidor.
function onStartup()
	print("[[ DATABASE CLEAN ]]")

	local inactivePlayer = doCheckInactivePlayer()
	if inactivePlayer > 0 then
		print(">> ".. inactivePlayer .. " deleted inactive players.")
	end

	local emptyAccounts = doCheckEmptyAccounts()
	if emptyAccounts > 0 then
		print(">> ".. emptyAccounts .." empty deleted accounts.")
	end

	local inactiveHouses = doCheckInactiveHouses()
	if inactiveHouses > 0 then
		print(">> ".. inactiveHouses .." houses that were expropriated.")
	end

	local inactiveHouseLists = doCheckInactiveHouseLists()
	if inactiveHouseLists > 0 then
		print(">> ".. inactiveHouseLists .." deleted inactive house lists.")
	end

	local inactiveGuilds = doCheckInactiveGuilds()
	if inactiveGuilds > 0 then
		print(">> ".. inactiveGuilds .." deleted inactive guilds.")
	end

	addEvent(saveServer, 5000)
end
