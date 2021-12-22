-- Trade Offline 2.0 by WooX --

local config = {
	priceLimit = 2000000000, -- 2kkk
	maxOffersPerPlayer = 5,
	offerLimitStor = 86420,
	exhaustionStorage = 86421,
	infoOnPopUp = true,
	infoMsgType = MESSAGE_STATUS_CONSOLE_BLUE,
	errorMsgType = MESSAGE_STATUS_CONSOLE_RED,
	successMsgType = MESSAGE_INFO_DESCR,
	helpMsg = "Enter the parameters (add, remove, active, buy, info).",
	goldItems = {2148, 2152, 2160},
	levelRequiredToAdd = 20,
}

local config = {
	valuePerOffer = 500,
	blockedItems = {2165, 2152, 2148, 2160, 2166, 2167, 2168, 2169, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2343, 2433, 2640, 6132, 6300, 6301, 9932, 9933}
}

local function getContainerItems(uid)
	local container = Container(uid)
	if not container then
		return false
	end

	local containerItems = {}
	local containerSize = container:getSize()
	for i = (containerSize - 1), 0, -1 do
		local itemContainer = pushThing(container:getItem(i))
		-- Check for containers with items inside
		local containerInside = Container(itemContainer.uid)
		if containerInside then
			local itemInside = pushThing(containerInside:getItem(0))
			if itemInside then
				return false
			end
		end

		local itemContainerCount = itemContainer and itemContainer:getCount() or 1
		local itemContainerCharges = "DEFAULT"
		local itemContainerDuration = "DEFAULT"
	
		local itemCharges = itemContainer:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if itemCharges then
			if itemCharges ~= 0 then
				itemContainerCharges = itemContainer:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		local itemDuration = itemContainer:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if itemDuration then
			if itemDuration ~= 0 then
				itemContainerDuration = itemContainer:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		containerItems[i + 1] = {id = itemContainer:getId(), count = itemContainerCount, charges = itemContainerCharges, duration = itemContainerDuration}
	end
	return #containerItems > 0 and containerItems or false
end

function onSay(player, words, param)
	if param == '' then
		player:sendTextMessage(config.errorMsgType, "Command param required.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local position = player:getPosition()
	local tile = Tile(position)
	if not tile then
		player:sendTextMessage(config.errorMsgType, "Invalid player position.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false	
	end

	if not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(config.errorMsgType, "You must be in the protection zone to use these commands.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local exhaustion = player:getStorageValue(config.exhaustionStorage)
	if (exhaustion - os.time()) > 0 then
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	param = string.lower(param)
	local word = param:splitTrimmed(",")
	
	player:setStorageValue(config.exhaustionStorage, 10 + os.time())

	-- !tradeoff add
	if word[1] == "add" then

		if player:getLevel() < config.levelRequiredToAdd then
			player:sendTextMessage(config.errorMsgType, "You don't have required level ".. config.levelRequiredToAdd ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

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
			player:sendTextMessage(config.errorMsgType, "Sorry you can't add more offers (max. " .. config.maxOffersPerPlayer .. ")")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not word[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the value of the offer or the item you want to buy. Ex: !tradeoff add, sellForValue, !tradeoff add, sellForItem or !tradeoff add, sellForItem, sellForCountItem")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local item = player:getSlotItem(CONST_SLOT_AMMO)
		local sellingItem = ItemType(item.uid)
		if not sellingItem then
			player:sendTextMessage(config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local sellingItemId = sellingItem:getId()
		if sellingItemId == 0 then
			player:sendTextMessage(config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not sellingItem:isMoveable() or not sellingItem:isPickupable() then
			player:sendTextMessage(config.errorMsgType, "You cannot add this item type as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if sellingItem:isCorpse() then
			player:sendTextMessage(config.errorMsgType, "You cannot add a corpse as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local sellingItemCount = sellingItem and sellingItem:getCount() or 1
		local sellingItemCharges = "DEFAULT"
		local sellingItemDuration = "DEFAULT"

		local itemCharges = sellingItem:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if itemCharges then
			if itemCharges ~= 0 then
				sellingItemCharges = sellingItem:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		local itemDuration = sellingItem:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if itemDuration then
			if itemDuration ~= 0 then
				sellingItemDuration = sellingItem:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		local sellingItemArticle = (sellingItemCount > 1 and sellingItemCount or (sellingItem:getArticle() ~= "" and sellingItem:getArticle() or ""))
		local sellingItemName = (sellingItemCount > 1 and sellingItem:getPluralName() or sellingItem:getName())

		local containerItems = getContainerItems(item.uid)
		local tradeType = 1 -- no container
		if containerItems then
			tradeType = 2 -- container
		end

		local message = ""
		local messagePayment = ""
		local playerGuid = player:getGuid()

		local itemPayment = "DEFAULT"
		local addOffer = "DEFAULT"
		local addOfferForItemCount = "DEFAULT"

		-- !tradeoff add, valor
		if isNumber(word[2]) then

			if table.contains(config.goldItems, sellingItemId) then
				player:sendTextMessage(config.errorMsgType, "You can't trade gold for gold.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local addOfferForMoney = tonumber(word[2])
			if addOfferForMoney < 1 then
				player:sendTextMessage(config.errorMsgType, "The offer must have a value greater than 0.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end			

			if addOfferForMoney > config.priceLimit then
				player:sendTextMessage(config.errorMsgType, "The offer may not exceed the value of "..config.priceLimit.." gold coins.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			addOffer = addOfferForMoney

			messagePayment = "for ".. addOfferForMoney .." gold coins."

		else -- !tradeoff add, item

			local addOfferForItemId = ItemType(word[2]):getId()

			if not addOfferForItemId then
				player:sendTextMessage(config.errorMsgType, "This item does not exist, check if it's name is correct.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if table.contains(config.goldItems, addOfferForItemId) then
				player:sendTextMessage(config.errorMsgType, "To sell for gold insert only the amount instead of item name.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if addOfferForItemId == sellingItemId then
				player:sendTextMessage(config.errorMsgType, "You can not trade equal items.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if addOfferForItemId:isCorpse() then
				player:sendTextMessage(config.errorMsgType, "You can not buy a corpse.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not addOfferForItemId:isMoveable() or not addOfferForItemId:isPickupable() then
				player:sendTextMessage(config.errorMsgType, "You cannot request this type of payment item.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			-- !tradeoff add, item, count
			if word[3] then
				if not addOfferForItemId:isStackable() then
					player:sendTextMessage(config.errorMsgType, "You can only select the quantity with stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				if not isNumber(word[3]) then
					player:sendTextMessage(config.errorMsgType, "You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end	

				addOfferForItemCount = tonumber(word[3])
				if addOfferForItemCount < 1 or addOfferForItemCount > 100 then
					player:sendTextMessage(config.errorMsgType, "You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end
			
			itemPayment = 1
			addOffer = addOfferForItemId

			local addOfferForItemArticle = (word[3] and addOfferForItemCount or (addOfferForItemId:getArticle() ~= "" and addOfferForItemId:getArticle() or ""))
			local addOfferForItemName = (word[3] and addOfferForItemCount and addOfferForItemId:getPluralName() or addOfferForItemId:getName())
			messagePayment = "for ".. addOfferForItemArticle .. " ".. (word[3] and addOfferForItemCount or "1") .. "x ".. addOfferForItemName .."."
		end

		local query = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "
			.. playerGuid ..", ".. tradeType ..", ".. sellingItemId ..", ".. sellingItemCount ..", ".. sellingItemCharges ..", ".. sellingItemDuration ..", ".. sellingItemName ..", ".. itemPayment ..", " 
			.. addOffer ..", ".. addOfferForItemCount ..", ".. os.time() ..")"

		if tradeType == 2 then -- Container
			if not containerItems then
				player:sendTextMessage(config.errorMsgType, "You can not have containers with items inside the main container.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query(query)

			for i = 1, #containerItems do
				db.query("INSERT INTO trade_off_container_items (offer_id, item_id, item_charges, item_duration, count) VALUES (LAST_INSERT_ID(), "
				..containerItems[i].id..", "..containerItems[i].charges..", "..containerItems[i].duration..", "..containerItems[i].count..")")
			end

			message = " with ".. #containerItems .." items inside"
		else
			db.query(query)
		end

		player:sendTextMessage(config.successMsgType, "You announced ".. sellingItemArticle .. " ".. sellingItemCount .. "x ".. sellingItemName .."".. message .." "
		.. messagePayment .." Check out the offer id on the website.")
	
		sellingItem:remove(1)

	-- !tradeoff remove
	elseif word[1] == "remove" then
		if not word[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to remove.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end	
		
		-- !tradeoff remove, offerID
		if not isNumber(word[2]) then
			player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local offerID = tonumber(word[2])
		local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = ".. offerID)
		local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `name` = " .. db.escapeString(enemyName))
		if not queryResult then
			player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerID = result.getNumber(queryResult, "player_id")
		local playerGuid = player:getGuid()

		if playerGuid ~= playerID then
			player:sendTextMessage(config.errorMsgType, "You can not remove someone else's offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local parcel = Game.createItem(ITEM_PARCEL)
		local itemID = result.getNumber(queryResult, "item_id")
		
		if ItemType(itemID):isContainer() then
			local itemRemove = Game.createItem(itemID)
			local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = ".. offerID)
			if itemsInside ~= false then
				repeat
					local subID = result.getNumber(itemsInside, "item_id")
					local subCharges = result.getNumber(itemsInside, "item_charges")
					local subDuration = result.getNumber(itemsInside, "item_duration")
					local subCount = result.getNumber(itemsInside, "count")

					if subDuration > 0 then
						local subItem = Game.createItem(subID)
						subItem:setAttribute(ITEM_ATTRIBUTE_DURATION, subDuration)
						itemRemove:addItemEx(Item(subItem))
					else
						local subItem
						if subCharges > 0 then
							subItem = Game.createItem(subID, subCharges)
						else
							subItem = Game.createItem(subID, subCount)
						end
						itemRemove:addItemEx(Item(subItem))
					end

				until not result.next(resultId)
				result.free(itemsInside)
				
				db.query("DELETE FROM trade_off_container_items WHERE offer_id = ".. offerID)
			end

			parcel:addItemEx(Item(itemRemove))

		else
			local itemCount = result.getDataInt(queryResult, "item_count")
			local itemCharges = result.getDataInt(itemsInside, "item_charges")
			local itemDuration = result.getDataInt(itemsInside, "item_duration")								
			
			if itemDuration > 0 then
				local item = Game.createItem(itemID)
				item:setAttribute(ITEM_ATTRIBUTE_DURATION, itemDuration)
				parcel:addItemEx(Item(item))
			else
				local item
				if itemCharges > 0 then
					item = Game.createItem(itemID, itemCharges)
				else
					item = Game.createItem(itemID, itemCount)
				end
				
				parcel:addItemEx(Item(item))
			end
		end

		result.free(queryResult)
		db.query("DELETE FROM trade_off_offers WHERE id = ".. offerID)

		local townId = Town(player:getTown():getId())	
		local townName = townId:getName()

		doPlayerSendMailByName(player:getName(), parcel, townId)
		
	--[[local parcel = Game.createItem(ITEM_PARCEL)
	local letter = Game.createItem(2598)
	letter:setAttribute(ITEM_ATTRIBUTE_TEXT, "funcionou")

	parcel:addItemEx(letter)
	parcel:addItem(11263)

	local depot = player:getDepotChest(1, true)
    if depot then
		depot:addItemEx(parcel)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "enviado depot ...")
    end
	]]--
		
		player:sendTextMessage(config.successMsgType, "You canceled your offer with ID: ".. offerID ..", the respective offer items were sent to ".. townName .." depot.")

		-- !tradeoff active
		elseif (word[1] == "active") then
			local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE player_id = "..getPlayerGUID(cid))
			if queryResult then
				local offersString = ""
				while queryResult ~= false do
					local offerID = result.getDataInt(queryResult, "id")
					if (not result.next(queryResult)) then
						offersString = offersString .. offerID
						break
					else
						offersString = offersString .. offerID.. ", "
					end
				end
				result.free(queryResult)
				doPlayerSendTextMessage(cid, config.infoMsgType, "Active offers ID: "..offersString..".")
			else
				doPlayerSendTextMessage(cid, config.infoMsgType, "You don't have any active offers.")
			end
		-- !tradeoff info
		elseif (word[1] == "info") then
			if (word[2]) then
				-- !tradeoff info, offerID
				if isNumber(word[2]) and tonumber(word[2]) then
					local offerID = tonumber(word[2])
					local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = "..offerID)
					if queryResult then
						local playerID = result.getDataInt(queryResult, "player_id")
						local tradeType = result.getDataInt(queryResult, "type")
						local itemID = result.getDataInt(queryResult, "item_id")
						local itemCount = result.getDataInt(queryResult, "item_count")
						local itemCharges = result.getDataInt(queryResult, "item_charges")
						local itemDuration = result.getDataInt(queryResult, "item_duration")
						local itemName = result.getDataString(queryResult, "item_name")
						local isTrade = result.getDataInt(queryResult, "item_trade")
						local cost = result.getDataLong(queryResult, "cost")
						local costCount = result.getDataInt(queryResult, "cost_count")
						local addedDate = result.getDataLong(queryResult, "date")
						
						local normalItem
						local offerCount
						if itemDuration > 0 or itemCharges > 0 then
							normalItem = false
							if itemDuration > 0 then
								offerCount = " with "..getTimeString(itemDuration).." left"
							elseif itemCharges > 0 then
								local plural = itemCharges > 1 and "s" or ""
								offerCount = " with "..itemCharges.." charge"..plural.." left"
							end
						else
							normalItem = true
							offerCount = itemCount > 1 and itemCount or getItemArticleById(itemID)
						end
						
						local tradeTypes = {[0] = "Sale", [1] = "Item VIP", [2] = "Container", [3] = "Trade"}
						local typeString = isTrade > 0 and tradeTypes[3] or tradeTypes[tradeType]
						
						local information = "[TRADE OFF] Information:\n"
						if normalItem then
							information = information .. "Offer: "..offerCount.." "..itemName
						else
							information = information .. "Offer: "..getItemArticleById(itemID).." "..itemName..offerCount
						end
						
						if isItemContainer(itemID) then
							local numItems = 0
							local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = "..offerID)
							if itemsInside then
								local itemsInsideString = "("
								while itemsInside ~= false do
									numItems = numItems + 1								
									local subID = result.getDataInt(itemsInside, "item_id")
									local subCharges = result.getDataInt(itemsInside, "item_charges")
									local subDuration = result.getDataInt(itemsInside, "item_duration")
									local subCount = result.getDataInt(itemsInside, "count")

									local normalItem
									local offerCount
									if subDuration > 0 or subCharges > 0 then
										normalItem = false
										if subDuration > 0 then
											offerCount = " with "..getTimeString(subDuration).." left"
										elseif subCharges > 0 then
											local plural = subCharges > 1 and "s" or ""
											offerCount = " with "..subCharges.." charge"..plural.." left"
										end					
									else						
										normalItem = true
										offerCount = subCount > 1 and subCount or getItemArticleById(subID)
									end
									
									if (not result.next(itemsInside)) then
										if normalItem then
											itemsInsideString = itemsInsideString .. offerCount .. " " .. getItemNameByCount(subID, subCount) .. ").\n"
										else
											itemsInsideString = itemsInsideString .. getItemArticleById(subID) .. " " .. getItemNameById(subID) .. offerCount ..").\n"
										end
										break
									else
										if normalItem then
											itemsInsideString = itemsInsideString .. offerCount .. " " .. getItemNameByCount(subID, subCount) .. ", "
										else
											itemsInsideString = itemsInsideString .. getItemArticleById(subID) .. " " .. getItemNameById(subID) .. offerCount ..", "
										end									
									end
								end
								result.free(itemsInside)
								information = information .." with "..numItems.." items inside.\n"
								information = information ..itemsInsideString
							end
						else
							information = information ..".\n"
						end
						
						if (isTrade == 0) then
							information = information .. "Price: "..cost.." gold coins.\n"
						else
							local offerCostCount = costCount > 1 and costCount or getItemArticleById(cost)
							information = information .. "Price: "..offerCostCount.." "..getItemNameById(cost)..".\n"
						end
						information = information .. "Type: "..typeString..".\n"				
						information = information .. "Added: "..os.date("%d/%m/%Y at %X%p", addedDate)..".\n"
						information = information .. "Added by: "..getPlayerNameByGUID(playerID)..".\n"
						
						result.free(queryResult)
						if config.infoOnPopUp then
							doPlayerPopupFYI(cid, information)
						else
							doPlayerSendTextMessage(cid, config.infoMsgType, information)
						end
					else
						doPlayerSendTextMessage(cid, config.errorMsgType, "Please, insert a valid offer ID.")
					end
				else
					doPlayerSendTextMessage(cid, config.errorMsgType, "Please, insert only numbers.")
				end
			else
				doPlayerSendTextMessage(cid, config.errorMsgType, "Please enter the offerID you want to know about.")
			end
		-- !tradeoff buy
		elseif (word[1] == "buy") then
			if (word[2]) then
				-- !tradeoff buy, offerID
				if isNumber(word[2]) and tonumber(word[2]) then
					local offerID = tonumber(word[2])
					local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = "..offerID)
					if queryResult then
						local owner = result.getDataInt(queryResult, "player_id")
						if getPlayerGUID(cid) ~= owner then
							local itemID = result.getDataInt(queryResult, "item_id")
							local itemCount = result.getDataInt(queryResult, "item_count")
							local itemCharges = result.getDataInt(itemsInside, "item_charges")
							local itemDuration = result.getDataInt(itemsInside, "item_duration")
							local isTrade = result.getDataInt(queryResult, "item_trade")
							local cost = result.getDataLong(queryResult, "cost")
							
							if isTrade > 0 then
								local ogCostCount
								local costCount = result.getDataInt(queryResult, "cost_count")
								local itemCostName = getItemNameByCount(cost, costCount)
								local count = costCount > 1 and costCount or getItemArticleById(cost)
								if not (getPlayerItemCount(cid, cost) >= costCount) then
									result.free(queryResult)
									doPlayerSendTextMessage(cid, config.errorMsgType, "You don't have "..count.." "..itemCostName.." to buy this offer.")
									return false
								elseif getItemDefaultDuration(cost) > 0 or getItemInfo(cost).charges > 0 then
									local item = getPlayerSlotItem(cid, CONST_SLOT_AMMO)
									if (item.uid > 0 and item.id == cost) then
										if getItemDefaultDuration(cost) > 0 then
											if getItemDuration(item.uid) < getItemDefaultDuration(cost) then
												result.free(queryResult)
												doPlayerSendTextMessage(cid, config.errorMsgType, "The "..itemCostName.." needs to be brand new.")
												return false
											end
										elseif getItemInfo(cost).charges > 0 then
											ogCostCount = costCount
											costCount = item.type
											if item.type < getItemInfo(cost).charges then
												result.free(queryResult)
												doPlayerSendTextMessage(cid, config.errorMsgType, "The "..itemCostName.." needs to be brand new.")
												return false
											end
										end
									else
										doPlayerSendTextMessage(cid, config.errorMsgType, "You need to put the "..itemCostName.." in your ammunition slot.")
										return false
									end
								end
								local ownerTownID						
								if isPlayerOnline(getPlayerNameByGUID(owner)) then								
									ownerTownID = getPlayerTown(getPlayerByGUID(owner))
									setPlayerStorageValue(getPlayerByGUID(owner), config.offerLimitStor, (tonumber(getPlayerStorageValue(getPlayerByGUID(owner), config.offerLimitStor))-1))
									doPlayerSendTextMessage(getPlayerByGUID(owner), config.successMsgType, "The player "..getPlayerName(cid).." just bought your offer with ID: "..offerID..", "..count.." "..itemCostName.." was sent to your "..getTownName(ownerTownID).." depot.")
								else
									local getTown = db.storeQuery("SELECT town_id FROM players WHERE id = "..owner)
									ownerTownID = result.getDataInt(getTown, "town_id")
									result.free(getTown)
									setOfflinePlayerStorage(owner, config.offerLimitStor, (tonumber(getOfflinePlayerStorage(owner, config.offerLimitStor))-1))
								end
								local parcel = doCreateItemEx(ITEM_PARCEL)
								doAddContainerItemEx(parcel, doCreateItemEx(cost, costCount))
								doPlayerSendMailByName(getPlayerNameByGUID(owner), parcel, ownerTownID)
								if ogCostCount then
									doPlayerRemoveItem(cid, cost, ogCostCount)
								else
									doPlayerRemoveItem(cid, cost, costCount)
								end
							else
								if not (getPlayerMoney(cid) >= cost) then
									result.free(queryResult)
									doPlayerSendTextMessage(cid, config.errorMsgType, "You don't have enough money to buy this offer.")
									return false
								end
								if isPlayerOnline(getPlayerNameByGUID(owner)) then
									local ownerCID = getPlayerByGUID(owner)
									setPlayerStorageValue(ownerCID, config.offerLimitStor, (tonumber(getPlayerStorageValue(getPlayerByGUID(owner), config.offerLimitStor))-1))
									doPlayerSendTextMessage(ownerCID, config.successMsgType, "The player "..getPlayerName(cid).." just bought your offer with ID: "..offerID..", "..cost.." gold coins were transfered to your bank account.")
									doPlayerSetBalance(ownerCID, getPlayerBalance(ownerCID) + cost)
								else
									local bank = db.storeQuery("SELECT balance FROM players WHERE id = "..owner)
									local balance = result.getDataLong(bank, "balance")
									result.free(bank)
									setOfflinePlayerStorage(owner, config.offerLimitStor, (tonumber(getOfflinePlayerStorage(owner, config.offerLimitStor))-1))
									db.query("UPDATE players SET balance = "..(balance + cost).." WHERE id = "..owner)									
								end
								doPlayerRemoveMoney(cid, cost)
							end						
							
							local parcel = doCreateItemEx(ITEM_PARCEL)
							if isItemContainer(itemID) then
								local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = "..offerID)
								if itemsInside then
									local container = doCreateItemEx(itemID)
									while itemsInside ~= false do
										local subID = result.getDataInt(itemsInside, "item_id")
										local subCharges = result.getDataInt(itemsInside, "item_charges")
										local subDuration = result.getDataInt(itemsInside, "item_duration")
										local subCount = result.getDataInt(itemsInside, "count")
										if subDuration > 0 then
											local subItem = doCreateItemEx(subID)
											doItemSetDuration(subItem, subDuration)
											doAddContainerItemEx(container, subItem)										
										else
											local subItem
											if subCharges > 0 then
												subItem = doCreateItemEx(subID, subCharges)
											else
												subItem = doCreateItemEx(subID, subCount)
											end
											doAddContainerItemEx(container, subItem)
										end
										if (not result.next(itemsInside)) then
											break
										end
									end
									result.free(itemsInside)
									db.query("DELETE FROM trade_off_container_items WHERE offer_id = "..offerID)
									doAddContainerItemEx(parcel, container)
								else
									local item = doCreateItemEx(itemID)
									doAddContainerItemEx(parcel, item)
								end
							else
								if itemDuration > 0 then
									local item = doCreateItemEx(itemID)
									doItemSetDuration(item, itemDuration)
									doAddContainerItemEx(parcel, item)
								elseif itemCharges > 0 then
									local item = doCreateItemEx(itemID, itemCharges)
									doAddContainerItemEx(parcel, item)
								else
									local item = doCreateItemEx(itemID, itemCount)
									doAddContainerItemEx(parcel, item)
								end
							end
							result.free(queryResult)
							db.query("DELETE FROM trade_off_offers WHERE id = "..offerID)
							doPlayerSendMailByName(getPlayerName(cid), parcel, getPlayerTown(cid))
							doPlayerSendTextMessage(cid, config.successMsgType, "You bought the offer with ID: "..offerID..", the respective offer items were sent to "..getTownName(getPlayerTown(cid)).." depot.")
						else
							doPlayerSendTextMessage(cid, config.errorMsgType, "You can not buy your own offer.")
						end
					else
						doPlayerSendTextMessage(cid, config.errorMsgType, "You can buy only active offers.")
					end
				else
					doPlayerSendTextMessage(cid, config.errorMsgType, "Please, insert only numbers.")
				end
			else
				doPlayerSendTextMessage(cid, config.errorMsgType, "Please enter the offerID you want to buy.")
			end		
		else
			doPlayerSendTextMessage(cid, config.infoMsgType, config.helpMsg)
		end
	else
		doPlayerSendTextMessage(cid, config.infoMsgType, config.helpMsg)
	end	
	return false
end

function getOfferID()
	local queryResult = db.storeQuery("SELECT LAST_INSERT_ID()")
	if (queryResult) then
		local offerID = result.getDataInt(queryResult, "LAST_INSERT_ID()")
		result.free(queryResult)
		return offerID
	end
	return false
end

function getItemDuration(uid)
	local itemID = getItemIdByName(getItemName(uid))
	if getItemDurationTime(uid) > 0 then
		return getItemDurationTime(uid)
	else
		return getItemDefaultDuration(itemID)
	end
end

function getItemDefaultDuration(itemID)
	if getItemInfo(itemID).decayTime <= 0 then
		if getItemInfo(itemID).transformUseTo > 0 then
			return getItemInfo(getItemInfo(itemID).transformUseTo).decayTime
		elseif getItemInfo(itemID).transformEquipTo > 0 then
			return getItemInfo(getItemInfo(itemID).transformEquipTo).decayTime
		end
	else
		return getItemInfo(itemID).decayTime
	end
	return 0
end
