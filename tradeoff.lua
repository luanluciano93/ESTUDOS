-- !offer add, itemName, itemCount, itemPrice     /     ex: !offer add, plate armor, 1, 500
-- !offer buy, AuctionID                          /     ex: !offer buy, 1943
-- !offer remove, AuctionID                       /     ex: !offer remove, 1943
-- !offer list

--[[
CREATE TABLE `tradeoff` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `item_id` int DEFAULT NULL,
  `item_name` varchar(256) NOT NULL DEFAULT '',
  `count` int NOT NULL DEFAULT '1',
  `cost` bigint unsigned NOT NULL DEFAULT '0',
  `date` int,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;

ALTER TABLE `players` ADD `tradeoff_balance` bigint unsigned NOT NULL DEFAULT '0';
]]--

local config = {
	levelRequiredToAdd = 20,
	maxOffersPerPlayer = 5,
	valuePerOffer = 500,
	blockedItems = {2165, 2152, 2148, 2160, 2166, 2167, 2168, 2169, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2343, 2433, 2640, 6132, 6300, 6301, 9932, 9933}
}

function onSay(player, words, param)
	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. TradeOff commands:" .. "\n"
			.. "!offer add, itemName, itemCount, itemPrice" .. "\n"
			.. "!offer buy, AuctionID" .. "\n"
			.. "!offer remove, AuctionID" .. "\n"
			.. "!offer list")		
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	elseif not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You must be in the protection zone to use these commands.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	elseif player:getExhaustion() > 0 then
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local word = param:splitTrimmed(",")
	if word[1] == "add" then
		if not word[2] or not word[3] or not word[4] then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. Ex: !offer add, ItemName, ItemCount, ItemPrice")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
		
		local itemCount = tonumber(word[3])
		local itemValue = tonumber(word[4])
		if not itemCount or not itemValue then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't set valid price or items count.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif itemCount < 1 or itemValue < 1 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You have to type a number higher than 0.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif string.len(itemCount) > 3 or string.len(itemValue) > 7 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This price or item count is too high.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getLevel() < config.levelRequiredToAdd then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have required level ".. config.levelRequiredToAdd ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		player:setExhaustion(5)

		local offers = 0
		local playerId = player:getGuid()
		local resultId = db.storeQuery("SELECT `id` FROM `tradeoff` WHERE `player_id` = " .. playerId)
		if resultId ~= false then
			repeat
				offers = offers + 1
			until not result.next(resultId)
			result.free(resultId)
		end

		if offers >= config.maxOffersPerPlayer then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Sorry you can't add more offers (max. " .. config.maxOffersPerPlayer .. ").")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemId = ItemType(word[2]):getId()
		itemCount = math.floor(itemCount)
		if itemId == 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Item wich such name does not exists.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif table.contains(config.blockedItems, itemId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This item is blocked.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getItemCount(itemId) < itemCount then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Sorry, you don't have this item(s).")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if player:getMoney() >= config.valuePerOffer then
			if not player:removeItem(itemId, itemCount) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You do not have the necessary items!")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			elseif not player:removeTotalMoney(config.valuePerOffer) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You need ".. config.valuePerOffer .." gold coins to add an offer in auction system.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			else
				local itemName = ItemType(itemId):getName()
				itemValue = math.floor(itemValue)
				db.query("INSERT INTO `tradeoff` (`player_id`, `item_name`, `item_id`, `count`, `cost`, `date`) VALUES (" .. playerId .. ", \"" .. db.escapeString(itemName) .. "\", " .. itemId .. ", " .. itemCount .. ", " .. itemValue ..", " .. os.time() .. ")")
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You successfully add " .. itemCount .." " .. itemName .." for " .. itemValue .. " gold coins to auction system.")
			end
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You need ".. config.valuePerOffer .." gold coins to add an offer in auction system.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
  
  

		return false

	elseif word[1] == "buy" then

		if not word[2] then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. Ex: /offer buy, AuctionID")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local id = tonumber(word[2])
		if not id then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Wrong ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		player:setExhaustion(5)

		local resultId = db.storeQuery("SELECT * FROM `tradeoff` WHERE `id` = " .. id)
		if resultId == false then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This offer does not exist.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerId = result.getNumber(resultId, "player_id")
		local itemValue = result.getNumber(resultId, "cost")
		local itemId = result.getNumber(resultId, "item_id")
		local itemCount = result.getNumber(resultId, "count")
		result.free(resultId)

		if player:getGuid() == playerId then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Sorry, you can't buy your own items.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getFreeCapacity() < ItemType(itemId):getWeight() then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have capacity.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif not player:removeTotalMoney(itemValue) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have enoguh gold coins.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		else
			player:addItem(itemId, itemCount)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You bought " .. itemCount .. " ".. ItemType(itemId):getName() .. " for " .. itemValue .. " gold coins in auction system!")
			db.query("DELETE FROM `tradeoff` WHERE `id` = " .. id)
								  
				 
															  
	   
			db.query('UPDATE `players` SET `tradeoff_balance` = `tradeoff_balance` + ' .. itemValue .. ' WHERE `id` = ' .. playerId)
	  
		end

		return false

	elseif word[1] == "remove" then

		if not word[2] then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. Ex: /offer remove, AuctionID")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local id = tonumber(word[2])
		if not id then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Wrong ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		player:setExhaustion(5)

		local resultId = db.storeQuery("SELECT * FROM `tradeoff` WHERE `id` = " .. id)
		if resultId == false then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This offer does not exist.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerId = result.getNumber(resultId, "player_id")
		local itemId = result.getNumber(resultId, "item_id")
		local itemCount = result.getNumber(resultId, "count")
		result.free(resultId)

		if player:getGuid() == playerId then
			if player:getFreeCapacity() < ItemType(itemId):getWeight() then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have capacity.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			else
				db.query("DELETE FROM `tradeoff` WHERE `id` = " .. id)
				player:addItem(itemId, itemCount)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your offert has been deleted from offerts database.")
			end
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This is not your offert.")
		end

		return false

	elseif word[1] == "list" then

		player:setExhaustion(5)

		local message = "Trade Offline:\n\n!offer add, ItemName, ItemCount, ItemPrice\n!offer buy, AuctionID\n!offer remove, AuctionID\n\n"
		local resultId = db.storeQuery("SELECT * FROM `tradeoff` ORDER BY `id` ASC")
		if resultId ~= false then
			repeat
				local auctionId = result.getNumber(resultId, "id")
				local itemId = result.getNumber(resultId, "item_id")
				local itemCount = result.getNumber(resultId, "count")
				local itemValue = result.getNumber(resultId, "cost")
				message = ""..message.."ID: ".. auctionId .." - ".. itemCount .." ".. ItemType(itemId):getName() .." for ".. itemValue .." gold coins.\n"
			until not result.next(resultId)
			result.free(resultId)
			player:popupFYI(message)
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "There is not offer in the system.")
		end
	end

	return false
end

