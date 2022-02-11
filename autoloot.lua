-- Revscript Auto Loot by luanluciano93 --

-- !autoloot clear
-- !autoloot show
-- !autoloot add, itemName          / ex: !autoloot add, fire sword
-- !autoloot remove, itemName       / ex: !autoloot remove, fire sword

local autoloot = {
	storageBase = 50000,
	storageGoldAtive = 9999,
	storageBoostTime = 9998,
	freeAccountLimit = 10,
	premiumAccountLimit = 20,
	loot_boost = {
		[2406] = 36, [2537] = 4800, [2377] = 480, [2663] = 600, [2472] = 240000, [2398] = 36, [2475] = 7200, [2519] = 6000, [2497] = 10800, [2523] = 180000, [2494] = 108000, [2400] = 144000,
		[2491] = 6000, [2421] = 108000, [2646] = 240000, [2477] = 7200, [2413] = 84, [2656] = 18000, [2498] = 48000, [2647] = 600, [2534] = 30000, [7402] = 24000, [2466] = 36000, [2465] = 240,
		[2408] = 120000, [2518] = 1800, [2500] = 3000, [2376] = 30, [2470] = 96000, [2388] = 24, [2645] = 48000, [2434] = 2400, [2463] = 480, [2536] = 9600, [2387] = 240, [2396] = 4800,
		[2381] = 240, [2528] = 4800, [2409] = 1800, [2414] = 12000, [2427] = 9000, [2407] = 7200, [2458] = 42, [2383] = 960, [2392] = 3600, [2488] = 18000, [2525] = 120, [2423] = 240, [2462] = 4800,
		[2520] = 48000, [2390] = 180000, [2417] = 72, [2436] = 1200, [5741] = 42000, [2378] = 120, [2487] = 24000, [2476] = 6000, [8891] = 36000, [2459] = 36, [2195] = 48000, [2391] = 7200,
		[2464] = 120, [8889] = 72000, [2432] = 12000, [2431] = 108000, [2492] = 72000, [2515] = 240, [2430] = 2400, [2393] = 12000, [7419] = 36000, [2522] = 120000, [2514] = 180000, [7418] = 26000
	}
}

local autolootCache = {}

local function getPlayerLimit(player)
	if player then
		return player:isPremium() and autoloot.premiumAccountLimit or autoloot.freeAccountLimit
	end
	return false
end

local function getPlayerAutolootItems(player)
    local limits = getPlayerLimit(player)
    if limits then
		local guid = player:getGuid()
		if guid then
			local itemsCache = autolootCache[guid]
			if itemsCache then
				if #itemsCache > limits then
					local newChache = {unpack(itemsCache, 1, limits)}
					autolootCache[guid] = newChache
					return newChache
				end
				return itemsCache
			end

			local items = {}
			for i = 1, limits do
				local itemType = ItemType(tonumber(player:getStorageValue(autoloot.storageBase + i)) or 0)
				if itemType then
					if itemType:getId() ~= 0 then
						items[#items +1] = itemType:getId()
					end
				end
			end

			autolootCache[guid] = items
			return items
		end
	end
	return false
end

local function setPlayerAutolootItems(player, items)
    local limit = getPlayerLimit(player)
	if limit then
		for i = 1, limit do
			player:setStorageValue(autoloot.storageBase + i, (items[i] and items[i] or -1))
		end
	end
	return true
end

local function addPlayerAutolootItem(player, itemId)
    local items = getPlayerAutolootItems(player)
	if items then
		for _, id in pairs(items) do
			if itemId == id then
				return false
			end
		end
		items[#items +1] = itemId
		return setPlayerAutolootItems(player, items)
	end
	return false
end

local function removePlayerAutolootItem(player, itemId)
    local items = getPlayerAutolootItems(player)
	if items then
		for i, id in pairs(items) do
			if itemId == id then
				table.remove(items, i)
				return setPlayerAutolootItems(player, items)
			end
		end
	end
    return false
end

local function hasPlayerAutolootItem(player, itemId)
	local items = getPlayerAutolootItems(player)	
	if items then
		for _, id in pairs(items) do
			if itemId then
				if itemId == id then
					return true
				end
			end
		end
	end
    return false
end

local ec = EventCallback

function ec.onDropLoot(monster, corpse)
    if not corpse:getType():isContainer() then
        return
    end

    local corpseOwner = Player(corpse:getCorpseOwner())
    if not corpseOwner then
        return
    end

    local items = corpse:getItems()
    if items then
		for _, item in pairs(items) do
			local currencyItems = Game.getCurrencyItems()
			if table.contains(currencyItems, item:getId()) and corpseOwner:getStorageValue(autoloot.storageGold) == 1 then
				local charges = item:getCharges()
				if charges then
					corpseOwner:setBankBalance(corpseOwner:getBankBalance() + charges)
					item:remove()
				end
			else
				if hasPlayerAutolootItem(corpseOwner, item:getId()) then
					local storageTime = corpseOwner:getStorageValue(autoloot.storageBoostTime) - os.time
					if storageTime > 0 then
						local boostItem = autoloot.loot_boost[item:getId()]
						if boostItem then
							corpseOwner:setBankBalance(corpseOwner:getBankBalance() + boostItem)
							item:remove()
						else
							if not item:moveTo(corpseOwner) then
								corpseOwner:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[AUTO LOOT] You no have capacity.")
								break
							end
						end
					else
						if not item:moveTo(corpseOwner) then
							corpseOwner:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[AUTO LOOT] You no have capacity.")
							break
						end
					end
				end
			end
		end
	end
end

ec:register(3)

local talkAction = TalkAction("!autolootasasa")

function talkAction.onSay(player, words, param, type)
    local split = param:splitTrimmed(",")
    local action = split[1]
    if not action then
		player:showTextDialog(2160, "[AUTO LOOT] Invalid parameters. Auto loot commands:" .. "\n"
			.. "!autoloot clear" .. "\n"
			.. "!autoloot show" .. "\n"
			.. "!autoloot add, itemName" .. "\n"
			.. "!autoloot remove, itemName".. "\n"
			.. "!autoloot gold".. "\n\n"
			.. "Available slots: ".. "\n"
			.. autoloot.freeAccountLimit .." free account".. "\n"
			.. autoloot.premiumAccountLimit .." premium account")
        return false
    end

	if not table.contains({"clear", "show", "add", "remove", "gold"}, action) then
		player:showTextDialog(2160, "[AUTO LOOT] Invalid parameters. Auto loot commands:" .. "\n"
			.. "!autoloot clear" .. "\n"
			.. "!autoloot show" .. "\n"
			.. "!autoloot add, itemName" .. "\n"
			.. "!autoloot remove, itemName".. "\n"
			.. "!autoloot gold".. "\n\n"
			.. "Available slots: ".. "\n"
			.. autoloot.freeAccountLimit .." free account".. "\n"
			.. autoloot.premiumAccountLimit .." premium account")
		return false
	end

	-- !autoloot clear
	if action == "clear" then
		setPlayerAutolootItems(player, {})
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[AUTO LOOT] Autoloot list cleaned.") 
		return false

	-- !autoloot show
	elseif action == "show" then
        local items = getPlayerAutolootItems(player)
        if items then
			local limit = getPlayerLimit(player)
			if limit then
				local description = {string.format('[AUTO LOOT] Your autoloot list, capacity: %d/%d ~\n', #items, limit)}
				for i, itemId in pairs(items) do
					description[#description +1] = string.format("%d) %s", i, ItemType(itemId):getName())
				end
				player:showTextDialog(2160, table.concat(description, '\n'), false)
			end
		end
        return false
    end

    local function getItemType()
        local itemType = ItemType(split[2])
        if not itemType or itemType:getId() == 0 then
            itemType = ItemType(tonumber(split[2]) or 0)
            if not itemType or itemType:getId() == 0 then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] The item %s does not exists!", split[2]))
                return false
            end
        end
        return itemType
    end

    -- !autoloot add, itemName
	if action == "add" then
        local itemType = getItemType()
        if itemType then
            local limits = getPlayerLimit(player)
			if limits then
				local items = getPlayerAutolootItems(player)
				if items then
					if #items >= limits then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Your auto loot only allows you to add %d items.", limits))
						return false
					end

					if addPlayerAutolootItem(player, itemType:getId()) then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Perfect you have added to the list: %s", itemType:getName()))
					else
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] The item %s already exists!", itemType:getName()))
					end
				end
			end
        end
        return false

	-- !autoloot remove, itemName
	elseif action == "remove" then
        local itemType = getItemType()
        if itemType then
			if removePlayerAutolootItem(player, itemType:getId()) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Perfect you have removed to the list the article: %s", itemType:getName()))
            else
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] The item %s does not exists in the list.", itemType:getName()))
            end
        end
        return false

	-- !autoloot gold
	elseif action == "gold" then
		player:setStorageValue(autoloot.storageGold, player:getStorageValue(autoloot.storageGold) == 1 and 0 or 1)
		local check = player:getStorageValue(autoloot.storageGold) == 1 and "ligou" or "desligou"
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[AUTO LOOT] Você ".. check .." a coleta de dinheiro.")
        return false
    end

    return false
end

talkAction:separator(" ")
talkAction:register()

local creatureEvent = CreatureEvent("autolootCleanCache")

function creatureEvent.onLogout(player)
    local items = getPlayerAutolootItems(player)
	if items then
		setPlayerAutolootItems(player, items)
		autolootCache[player:getGuid()] = nil
	end
    return true
end

creatureEvent:register()
