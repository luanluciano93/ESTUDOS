local autoloot = {
    talkaction = "!autoloot",
    storageBase = 50000,
    freeAccountLimit = 10,
    premiumAccountLimit = 20
}

local autolootCache = {}

local function getPlayerLimit(player)
    return player:isPremium() and autoloot.premiumAccountLimit or autoloot.freeAccountLimit
end

local function getPlayerAutolootItems(player)
    local limits = getPlayerLimit(player)
    local guid = player:getGuid()
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
        if itemType and itemType:getId() ~= 0 then
            items[#items +1] = itemType:getId()
        end
    end

    autolootCache[guid] = items
    return items
end

local function setPlayerAutolootItems(player, items)
    for i = 1, getPlayerLimit(player) do
        player:setStorageValue(autoloot.storageBase + i, (items[i] and items[i] or -1))
    end
    return true
end

local function addPlayerAutolootItem(player, itemId)
    local items = getPlayerAutolootItems(player)
    for _, id in pairs(items) do
        if itemId == id then
            return false
        end
    end
    items[#items +1] = itemId
    return setPlayerAutolootItems(player, items)
end

local function removePlayerAutolootItem(player, itemId)
    local items = getPlayerAutolootItems(player)
    for i, id in pairs(items) do
        if itemId == id then
            table.remove(items, i)
            return setPlayerAutolootItems(player, items)
        end
    end
    return false
end

local function hasPlayerAutolootItem(player, itemId)
    for _, id in pairs(getPlayerAutolootItems(player)) do
        if itemId == id then
            return true
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
    local items = corpse:getItems()
    for _, item in pairs(items) do
        if hasPlayerAutolootItem(corpseOwner, item:getId()) then
            if not item:moveTo(corpseOwner) then
                corpseOwner:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You no have capacity.")
                break
            end
        end
    end
end

ec:register(3)

local talkAction = TalkAction(autoloot.talkaction)

function talkAction.onSay(player, words, param, type)
    local split = param:splitTrimmed(",")
    local action = split[1]
    if not action then
        player:showTextDialog(2160, string.format("Examples of use:\n%s add,gold coin\n%s remove,gold coin\n%s clear\n%s show\n\n~Available slots~\nfreeAccount: %d\npremiumAccount: %d", words, words, words, words, autoloot.freeAccountLimit, autoloot.premiumAccountLimit), false)
        return false
    end

    if action == "clear" then
        setPlayerAutolootItems(player, {})
        player:sendCancelMessage("Autoloot list cleaned.")
        return false
    elseif action == "show" then
        local items = getPlayerAutolootItems(player)
        local description = {string.format('~ Your autoloot list, capacity: %d/%d ~\n', #items, getPlayerLimit(player))}
        for i, itemId in pairs(items) do
            description[#description +1] = string.format("%d) %s", i, ItemType(itemId):getName())
        end
        player:showTextDialog(2160, table.concat(description, '\n'), false)
        return false
    end

    local function getItemType()
        local itemType = ItemType(split[2])
        if not itemType or itemType:getId() == 0 then
            itemType = ItemType(tonumber(split[2]) or 0)
            if not itemType or itemType:getId() == 0 then
                player:sendCancelMessage(string.format("The item %s does not exists!", split[2]))
                return false
            end
        end
        return itemType
    end

    if action == "add" then
        local itemType = getItemType()
        if itemType then
            local limits = getPlayerLimit(player)
            if #getPlayerAutolootItems(player) >= limits then
                player:sendCancelMessage(string.format("Your auto loot only allows you to add %d items.", limits))
                return false
            end

            if addPlayerAutolootItem(player, itemType:getId()) then
                player:sendCancelMessage(string.format("Perfect you have added to the list: %s", itemType:getName()))
            else
                player:sendCancelMessage(string.format("The item %s already exists!", itemType:getName()))
            end
        end
        return false
    elseif action == "remove" then
        local itemType = getItemType()
        if itemType then
            if removePlayerAutolootItem(player, itemType:getId()) then
                player:sendCancelMessage(string.format("Perfect you have removed to the list the article: %s", itemType:getName()))
            else
                player:sendCancelMessage(string.format("The item %s does not exists in the list.", itemType:getName()))
            end
        end
        return false
    end

    return false
end

talkAction:separator(" ")
talkAction:register()

local creatureEvent = CreatureEvent("autolootCleanCache")

function creatureEvent.onLogout(player)
    setPlayerAutolootItems(player, getPlayerAutolootItems(player))
    autolootCache[player:getGuid()] = nil
    return true
end

creatureEvent:register()
