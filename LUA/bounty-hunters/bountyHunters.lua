-- https://otland.net/threads/tfs-1-x-bounty-hunter-system.213135/

-- Instalação automática de tabelas se ainda não as tivermos (primeira instalação)
db.query([[
	CREATE TABLE IF NOT EXISTS `bounty_hunter_system` (
		`id` int unsigned NOT NULL AUTO_INCREMENT,
		`hunter_id` int NOT NULL,
		`target_id` int NOT NULL,
		`killer_id` int NOT NULL,
		`prize` bigint unsigned NOT NULL DEFAULT '0',
		`currencyType` varchar(255) NOT NULL,
		`dateAdded` bigint unsigned NOT NULL,
		`killed` int NOT NULL, ???????????????????????????????????????
		`dateKilled` bigint unsigned NOT NULL,
		PRIMARY KEY (`id`),
		FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE ????????????????????????????????????????????????????????????
	) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
]])

--------------------------------------
---------- START OF CONFIG -----------
--------------------------------------
local customCurrency = '' -- por padrão, o saldo bancário e os pontos premium estão incluídos, mas você pode adicionar outras moedas empilháveis ​​como gold nuggets, etc. aqui, por exemplo, 'gold nugget' ou você pode usar o itemID ou o nome do item
local config = {
    ipCheck = true, -- jogadores do mesmo IP não podem colocar recompensas uns nos outros
    minLevelToAddBounty = 20, -- min lvl req para colocar uma recompensa
    minLevelToBeTargeted = 20, -- min lvl req para ser alvo de uma recompensa
    broadcastKills = true, -- Deve transmitir uma mensagem para todo o mundo do jogo quando alguém foi morto?
    broadcastHunt = true, -- Deve transmitir uma mensagem para todo o mundo do jogo quando alguém é adicionado à lista de recompensas?
    mailbox_position = Position(32351,32223,6), -- Se você estiver usando uma moeda personalizada então nós a enviaremos para a caixa de correio dos jogadores, para fazer isso você só precisa colocar a localização de uma caixa de correio do seu mapa aqui, não importa qual
    currencies = {
        ['gold'] = {  
            minAmount = 1000000, -- Quantidade mínima de gold coins permitida
            maxAmount = 1000000000, -- Quantidade máxima de gold coins permitida
            func =
                function(player, prize, currency)
                    return player:setBankBalance(player:getBankBalance() + prize)
                end,
            check =
                function(player, amount, currency)
                    if player:getBankBalance() >= amount then
                        return player:setBankBalance(player:getBankBalance() - amount)
                    end
                    return false
                end,
        },
        ['points'] = {
            minAmount = 10, -- Quantidade mínima de points permitida
            maxAmount = 500, -- Quantidade máxima de points permitida
            func =
                function(player, prize, currency)
                    return player:addPremiumPoints(prize)
                end,
            check =
                function(player, prize, currency)
                    if player:getPremiumPoints() > prize then
                        return player:removePremiumPoints(prize)
                    end
                    return false
                end
        },
        [customCurrency] = {
            minAmount = 10, -- Quantidade mínima de custom item permitida
            maxAmount = 3000, -- Quantidade máxima de custom item permitida
            func =
                function(player, prize, currency)
                    return player:sendParcel(prize)
                end,
            check =
                function(player, amount, currency)
                    local itemID = ItemType(customCurrency):getId()
                    if itemID > 0 and player:getItemCount(itemID) >= amount then
                        player:removeItem(itemID, amount)
                        return true
                    end
                    return false
                end,
        }
    }
}
--------------------------------------
----------- END OF CONFIG ------------
--------------------------------------
-- Só edite abaixo se você souber o que está fazendo --

local function trimString(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function addItemsToBag(bpID, itemID, count)
    local masterBag = Game.createItem(bpID,1)
    local stackable = ItemType(itemID):isStackable()

    if stackable then
        if count > 2000 then
            local bp = Game.createItem(bpID,1)
            masterBag:addItemEx(bp)
            for i = 1, count do
                if bp:getEmptySlots() < 1 then
                    bp = Game.createItem(bpID,1)
                    masterBag:addItemEx(bp)
                end
                bp:addItem(itemID)
            end
        end
        return masterBag
    end

    if count > 20 then
        local bp = Game.createItem(bpID,1)
        masterBag:addItemEx(bp)
        for i = 1, count do
            if bp:getEmptySlots() < 1 then
                bp = Game.createItem(bpID,1)
                masterBag:addItemEx(bp)
            end
            bp:addItem(itemID)
        end
    return masterBag
    end

    for i = 1, count do
        masterBag:addItem(itemID)
    end
    return masterBag
end

function Player:sendParcel(amount)
    local itemID = ItemType(customCurrency):getId()
    if itemID == 0 then
        print('Error in sending parcel. Custom currency was not set properly double check the spelling.')
        return
    end
    local container = Game.createItem(2595, 1)
    container:setAttribute(ITEM_ATTRIBUTE_NAME, 'Bounty Hunters Mail')
    local label = container:addItem(2599, 1)
    label:setAttribute(ITEM_ATTRIBUTE_TEXT, self:getName())
    label:setAttribute(ITEM_ATTRIBUTE_WRITER, "Bounty Hunters Mail")
    local parcel = addItemsToBag(1988, itemID, amount)
    container:addItemEx(parcel)
    container:moveTo(config.mailbox_position)
end

function Player:getPremiumPoints(points)
    local points = db.storeQuery("SELECT `premium_points` FROM `accounts` WHERE `id` = " .. self:getAccountId() .. ";")
    if points then
        local pointTotal = result.getDataInt(points, "premium_points")
        result.free(points)
    return pointTotal
    end
    return 0
end

function Player:addPremiumPoints(points)
    return db.query("UPDATE accounts SET premium_points = premium_points + "..points.." where id = "..self:getAccountId()..";")
end

function Player:removePremiumPoints(points)
    return db.query("UPDATE accounts SET premium_points = premium_points - "..points.." where id = "..self:getAccountId()..";")
end

function Player:getBountyInfo()
    local result_plr = db.storeQuery("SELECT prize, id, currencyType FROM `bounty_hunter_system` WHERE `target_id` = "..self:getGuid().." AND `killed` = 0;")
    if (result_plr == false) then
        return {false, 0, 0, 0, 0}
    end
    local prize = tonumber(result.getDataInt(result_plr, "prize"))
    local id = tonumber(result.getDataInt(result_plr, "id"))
    local bounty_type = tostring(result.getDataString(result_plr, "currencyType"))
    result.free(result_plr)
    return {true, prize, id, bounty_type, currency}
end

local function addBountyKill(killer, target, prize, id, bounty_type, currency)
    if not config.currencies[bounty_type] then
        print('error in adding bounty prize')
        return true
    end
    config.currencies[bounty_type].func(killer, prize, currency)
    db.query("UPDATE `bounty_hunter_system` SET `killed` = 1, `killer_id`="..killer:getGuid()..", `dateKilled` = " .. os.time() .. " WHERE `id`  = "..id..";")
    killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,'[BOUNTY HUNTER SYSTEM] You killed ' .. target:getName() .. ' and earned a reward of ' .. prize .. ' ' .. bounty_type .. 's!')
    if config.broadcastKills then
        Game.broadcastMessage("Bounty Hunter Update:\n " .. killer:getName() .. " has killed " .. target:getName() .. " and earned a reward of " .. prize .. " " .. bounty_type .. "!", MESSAGE_EVENT_ADVANCE)
    end
    return true
end

local function addBountyHunt(player, target, amount, currencyType)
    db.query("INSERT INTO `bounty_hunter_system` VALUES (NULL," .. player:getGuid() .. "," .. target:getGuid() .. ",0," .. amount .. ", '" .. currencyType .. "', " .. os.time() .. ", 0, 0);")
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[BOUNTY HUNTER SYSTEM] You have placed bounty on " .. target:getName() .. " for a reward of " .. amount .. " " .. currencyType .. "!")
    if config.broadcastHunt then
        Game.broadcastMessage("[BOUNTY_HUNTER_SYSTEM]\n " .. player:getName() .. " has put a bounty on " .. target:getName() .. " for " .. amount .. " " .. t[2] .. ".", MESSAGE_EVENT_ADVANCE)
    end
return false
end

local bounty_hunter_talkaction = TalkAction("!hunt")
function bounty_hunter_talkaction.onSay(player, words, param)

    if player:getLevel() < config.minLevelToAddBounty then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] You need level ' .. config.minLevelToAddBounty .. ' to use this command.')
        return false
    end
    local t = param:split(",")
    local name = t[1]
    local currencyType = t[2] and trimString(t[2]) or nil
    local amount = t[3] and tonumber(t[3]) or nil

    if not (name and currencyType and amount) then
        local item = ItemType(customCurrency)
        local text = '[BOUNTY HUNTER SYSTEM GUIDE]\n\nCommand Usage:\n!hunt playerName, type(gold/' .. customCurrency .. '/points), amount' .. '\n\n' .. 'Hunting for Gold:\n' .. '--> !hunt Joe,gold,150000\n' .. '--> Placed a bounty on Joe for the amount of 150,000 gps.' .. '\n\n' .. 'Hunting for Premium Points:\n' .. '--> !hunt Joe,points,100\n' .. '--> Placed a bounty on Joe for the amount of 100 premium points.'
        text = text .. (item:getId() > 0 and ('\n\n' .. 'Hunting for ' .. item:getPluralName() .. ':\n' .. '--> !hunt Joe,' .. customCurrency .. ',50\n' .. '--> Placed a bounty on Joe for the amount of 50 ' .. item:getPluralName()) or '')
        player:popupFYI(text)
        return false
    end

    local target = Player(name)
    if not target then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] A player with the name of ' .. name .. ' is not online.')
    return false
    end

    if target:getGuid() == player:getGuid() then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] You may not place a bounty on yourself!')
    return false
    end

    if config.ipCheck and target:getIp() == player:getIp() then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] You may not place a bounty on a player from the same IP Address!')
    return false
    end

    if target:getLevel() < config.minLevelToBeTargeted then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] You may only target players level ' .. config.minLevelToBeTargeted .. ' and above!')
    return false
    end

    local info = target:getBountyInfo()
    if info[1] then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[BOUNTY HUNTER SYSTEM] This player has already been hunted.")
        return false
    end

    local typ = config.currencies[currencyType]
    if not typ then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] The currency type "' .. currencyType .. '" is not a valid bounty currency. [Currencies: gold/points' .. (customCurrency ~= '' and '/'..customCurrency..'' or '') .. ']')
    return false
    end

    local minA, maxA = typ.minAmount, typ.maxAmount
    if amount < minA or amount > maxA then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] The currency type of "' .. currencyType .. '" allows the amount to be in the range of ' .. minA .. ' --> ' .. maxA .. '.')
    return false
    end

    if not typ.check(player, amount, currencyType) then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BOUNTY_HUNTER_SYSTEM] You do not have ' .. amount .. ' ' .. currencyType .. '. [Error: Insufficient Funds]')
    return false
    end

    return addBountyHunt(player, target, amount, currencyType)
end
bounty_hunter_talkaction:separator(" ")
bounty_hunter_talkaction:register()

local bounty_hunter_kill = CreatureEvent("BountyHunterKill")
function bounty_hunter_kill.onKill(creature, target)
    if not target:isPlayer() then
        return true
    end

    if creature:getTile():hasFlag(TILESTATE_PVPZONE) then
        return true
    end

    local info = target:getBountyInfo()
    if not info[1] then
        return true
    end

    return addBountyKill(creature, target, info[2], info[3], info[4], info[5])
end
bounty_hunter_kill:register()

local bounty_hunter_login = CreatureEvent("BountyHunterLogin")
function bounty_hunter_login.onLogin(player)
    player:registerEvent("BountyHunterKill")
    return true
end
bounty_hunter_login:register()
