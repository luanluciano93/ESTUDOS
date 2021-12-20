-- Trade Offline 2.0 by WooX --

local config = {
	priceLimit = 2000000000, -- 2kkk
	offerLimit = 3,
	offerLimitStor = 86420,
	exhaustionStorage = 86421,
	infoOnPopUp = true,
	infoMsgType = MESSAGE_STATUS_CONSOLE_BLUE,
	errorMsgType = MESSAGE_STATUS_CONSOLE_RED,
	successMsgType = MESSAGE_INFO_DESCR,
	helpMsg = "Enter the parameters (add, remove, active, buy, info).",
	goldItems = {2148, 2152, 2160},
	itemsVIP = {4540, 4545, 4560},
}

local config = {
	levelRequiredToAdd = 20,
	maxOffersPerPlayer = 5,
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
		local item = pushThing(container:getItem(i))
		-- Check for containers with items inside
		local containerInside = Container(item.uid)
		if containerInside then
			local itemInside = pushThing(containerInside:getItem(0))
			if itemInside then
				return false
			end
		end

		local count = 1
		local charges = "DEFAULT"
		local duration = "DEFAULT"

		local itemCount = item:getCharges()
		if itemCount ~= 0 then
			count = itemCount
		end
	
		local itemCharges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if itemCharges then
			if itemCharges ~= 0 then
				charges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		local itemDuration = item:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if itemDuration then
			if itemDuration ~= 0 then
				charges = item:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		containerItems[i + 1] = {id = item:getId(), count = count, charges = charges, duration = duration}
	end
	return containerItems
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
		if not word[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the value of the offer or the item you want to buy.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if player:getLevel() < config.levelRequiredToAdd then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't have required level ".. config.levelRequiredToAdd ..".")
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
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sorry you can't add more offers (max. " .. config.maxOffersPerPlayer .. ")")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local item = player:getSlotItem(CONST_SLOT_AMMO)
		if not item or item.itemid == 0 then
			doPlayerSendTextMessage(cid, config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			return true
		end

		local itemType = ItemType(item.uid)
		if itemType:getId() == 0 then
			doPlayerSendTextMessage(cid, config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			return true
		end

		if not itemType:isMoveable() then
			doPlayerSendTextMessage(cid, config.errorMsgType, "You cannot add a property as an offer.")
			return true
		end

		if itemType:isCorpse() then
			doPlayerSendTextMessage(cid, config.errorMsgType, "You cannot add a corpse as an offer.")
			return true
		end

		local containerItems = getContainerItems(item.uid)
			
		local tradeType = 0
		local container = Container(item.uid)
		if table.contains(config.itemsVIP, item:getId()) and (not containerItems or (container and not containerItems[1])) then
			tradeType = 1 -- itemVip
		elseif container then
			tradeType = 2 -- Container
		end

		local count = 1
		local charges = "DEFAULT"
		local duration = "DEFAULT"

		local itemCount = itemType:getCharges()
		if itemCount ~= 0 then
			count = itemCount
		end

		local itemCharges = itemType:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if itemCharges then
			if itemCharges ~= 0 then
				charges = itemType:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		local itemDuration = itemType:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if itemDuration then
			if itemDuration ~= 0 then
				charges = itemType:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		local itemArticle = (count > 1 and count or (itemType:getArticle() ~= "" and itemType:getArticle() or ""))

		-- !tradeoff add, valor
		if isNumber(word[2]) then

			if table.contains(config.goldItems, item:getId()) then
				player:sendTextMessage(config.errorMsgType, "You can't trade gold for gold.")
			end

			local goldWord = tonumber(word[2])
			if goldWord <= 0 then
				doPlayerSendTextMessage(cid, config.errorMsgType, "The offer must have a value greater than 0.")
			end			

			if goldWord > config.priceLimit then
				doPlayerSendTextMessage(cid, config.errorMsgType, "The offer may not exceed the value of "..config.priceLimit.." gold coins.")
			end			

								local offerID
								local itemsString = ""
								if tradeType == 2 then
									if not containerItems then
										doPlayerSendTextMessage(cid, config.errorMsgType, "You can not have containers with items inside the main container.")
										return true
									end										

									local query = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "..getPlayerGUID(cid)..", "..tradeType..", "..item.id..", "..count..", "..charges..", "..duration..", \""..getItemNameByCount(item.id, count).."\", DEFAULT, "..word[2]..", DEFAULT, "..os.time()..")"
									db.query(query)
									offerID = getOfferID()
									for i = 1, #containerItems do
										db.query("INSERT INTO trade_off_container_items (offer_id, item_id, item_charges, item_duration, count) VALUES (LAST_INSERT_ID(), "..containerItems[i].id..", "..containerItems[i].charges..", "..containerItems[i].duration..", "..containerItems[i].count..")")
									end
									itemsString = " with ".. #containerItems .." items inside"
								else
									local query = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "..getPlayerGUID(cid)..", "..tradeType..", "..item.id..", "..count..", "..charges..", "..duration..", \""..getItemNameByCount(item.id, count).."\", DEFAULT, "..word[2]..", DEFAULT, "..os.time()..")"
									db.query(query)
									offerID = getOfferID()
								end
								itemsString = itemsString ~= "" and itemsString or ""
								doPlayerSendTextMessage(cid, config.successMsgType, "You announced "..itemArticle.." "..getItemNameByCount(item.id, count)..""..itemsString.." for "..word[2].." gold coins, your offerID is "..offerID..".")
								doRemoveItem(item.uid)


				else
					-- !tradeoff add, item
					errors(false)
					local tradeItemID = getItemIdByName(word[2])
					errors(true)
					if tradeItemID then
						if isInArray(config.goldItems, tradeItemID) then
							doPlayerSendTextMessage(cid, config.errorMsgType, "To sell for gold insert only the amount instead of item name.")
							return true
						elseif (tradeItemID == item.id) then
							doPlayerSendTextMessage(cid, config.errorMsgType, "You can not trade equal items.")
							return true						
						elseif getItemInfo(tradeItemID).corpseType > 0 then
							doPlayerSendTextMessage(cid, config.errorMsgType, "You can not buy a corpse.")
							return true
						elseif not getItemInfo(tradeItemID).pickupable then
							doPlayerSendTextMessage(cid, config.errorMsgType, "You can not buy "..getItemArticleById(tradeItemID).." "..getItemNameById(tradeItemID)..".")
							return true
						end
						local costCount
						if word[3] then
							if isItemStackable(tradeItemID) then
								if isNumber(word[3]) and tonumber(word[3]) > 0 and tonumber(word[3]) <= 100 then
									costCount = tonumber(word[3])
									local query = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "..getPlayerGUID(cid)..", "..tradeType..", "..item.id..", "..count..", "..charges..", "..duration..", \""..getItemNameByCount(item.id, count).."\", 1, "..tradeItemID..", "..costCount..", "..os.time()..")"
									db.query(query)
								else
									doPlayerSendTextMessage(cid, config.errorMsgType, "You can only receive from 1 to 100 stackable items.")
									return true
								end
							else
								doPlayerSendTextMessage(cid, config.errorMsgType, "You can only select the quantity with stackable items.")
								return true
							end
						else
							local query = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "..getPlayerGUID(cid)..", "..tradeType..", "..item.id..", "..count..", "..charges..", "..duration..", \""..getItemNameByCount(item.id, count).."\", 1, "..tradeItemID..", DEFAULT, "..os.time()..")"
							db.query(query)
						end
						local offerID = getOfferID()
						local itemsString = ""
						if (tradeType == 2) then
							if containerItems then
								for i = 1, #containerItems do
									db.query("INSERT INTO trade_off_container_items (offer_id, item_id, item_charges, item_duration, count) VALUES (LAST_INSERT_ID(), "..containerItems[i].id..", "..containerItems[i].charges..", "..containerItems[i].duration..", "..containerItems[i].count..")")
								end
								itemsString = " with ".. #containerItems .." items inside"
							else
								doPlayerSendTextMessage(cid, config.errorMsgType, "You can not have containers with items inside the main container.")
								return true
							end
						end
						costCount = costCount and costCount > 1 and costCount or getItemArticleById(tradeItemID)
						itemsString = itemsString ~= "" and itemsString or ""
						doPlayerSendTextMessage(cid, config.successMsgType, "You announced "..itemArticle.." "..getItemNameByCount(item.id, count)..""..itemsString.." for "..costCount.." "..getItemNameByCount(tradeItemID, costCount)..", your offerID is "..offerID..".")	
						setPlayerStorageValue(cid, config.offerLimitStor, numOffer+1)
						doRemoveItem(item.uid)
					else
						doPlayerSendTextMessage(cid, config.errorMsgType, "This item does not exist, check if it's name is correct.")
					end
				end
			else
				doPlayerSendTextMessage(cid, config.errorMsgType, "Please enter the value of the offer or the item you want to buy.")
			end
			
			
			

		-- !tradeoff remove
		elseif (word[1] == "remove") then
			if (word[2]) then
				-- !tradeoff remove, offerID
				if isNumber(word[2]) and tonumber(word[2]) then
					local offerID = tonumber(word[2])
					local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = "..offerID)
					if queryResult then
						local playerID = result.getDataInt(queryResult, "player_id")
						if getPlayerGUID(cid) == playerID then
							local parcel = doCreateItemEx(ITEM_PARCEL)
							local itemID = result.getDataInt(queryResult, "item_id")
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
								local itemCount = result.getDataInt(queryResult, "item_count")
								local itemCharges = result.getDataInt(itemsInside, "item_charges")
								local itemDuration = result.getDataInt(itemsInside, "item_duration")								
								if itemDuration > 0 then
									local item = doCreateItemEx(itemID)
									doItemSetDuration(item, itemDuration)
									doAddContainerItemEx(parcel, item)
								else
									local item
									if itemCharges > 0 then
										item = doCreateItemEx(itemID, itemCharges)
									else
										item = doCreateItemEx(itemID, itemCount)
									end
									doAddContainerItemEx(parcel, item)
								end
							end
							result.free(queryResult)
							db.query("DELETE FROM trade_off_offers WHERE id = "..offerID)
							setPlayerStorageValue(cid, config.offerLimitStor, numOffer-1)
							doPlayerSendMailByName(getPlayerName(cid), parcel, getPlayerTown(cid))
							doPlayerSendTextMessage(cid, config.successMsgType, "You canceled your offer with ID: "..offerID..", the respective offer items were sent to "..getTownName(getPlayerTown(cid)).." depot.")
						else
							doPlayerSendTextMessage(cid, config.errorMsgType, "You can not remove someone else's offer.")
						end
					else
						doPlayerSendTextMessage(cid, config.errorMsgType, "Please, insert a valid offer ID.")
					end
				else
					doPlayerSendTextMessage(cid, config.errorMsgType, "Please, insert only numbers.")
				end
			else
				doPlayerSendTextMessage(cid, config.errorMsgType, "Please enter the offerID you want to remove.")
			end
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
									return true
								elseif getItemDefaultDuration(cost) > 0 or getItemInfo(cost).charges > 0 then
									local item = getPlayerSlotItem(cid, CONST_SLOT_AMMO)
									if (item.uid > 0 and item.id == cost) then
										if getItemDefaultDuration(cost) > 0 then
											if getItemDuration(item.uid) < getItemDefaultDuration(cost) then
												result.free(queryResult)
												doPlayerSendTextMessage(cid, config.errorMsgType, "The "..itemCostName.." needs to be brand new.")
												return true
											end
										elseif getItemInfo(cost).charges > 0 then
											ogCostCount = costCount
											costCount = item.type
											if item.type < getItemInfo(cost).charges then
												result.free(queryResult)
												doPlayerSendTextMessage(cid, config.errorMsgType, "The "..itemCostName.." needs to be brand new.")
												return true
											end
										end
									else
										doPlayerSendTextMessage(cid, config.errorMsgType, "You need to put the "..itemCostName.." in your ammunition slot.")
										return true
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
									return true
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
	return true
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
