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
			local itemCount = result.getNumber(queryResult, "item_count")
			local itemCharges = result.getNumber(itemsInside, "item_charges")
			local itemDuration = result.getNumber(itemsInside, "item_duration")								
			
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
		local letter = Game.createItem(2598)
		letter:setAttribute(ITEM_ATTRIBUTE_TEXT, "You canceled your offer with ID: ".. offerID ..".")
		parcel:addItemEx(Item(letter))
		local depot = player:getDepotChest(townId, true)
		if depot then
			depot:addItemEx(parcel)
			player:sendTextMessage(config.successMsgType, "You canceled your offer with ID: ".. offerID ..", the respective offer items were sent to ".. townName .." depot.")
		end

		-- !tradeoff active
		elseif word[1] == "active" then
			local playerGuid = player:getGuid()
			local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE player_id = ".. playerGuid)
			if queryResult ~= false then
				local offersString = ""
				while queryResult ~= false do
					local offerID = result.getNumber(queryResult, "id")
					if not result.next(queryResult) then
						offersString = offersString .. offerID
						break
					else
						offersString = offersString .. offerID.. ", "
					end
				end
				result.free(queryResult)
				player:sendTextMessage(config.successMsgType, "Active offers ID: ".. offersString ..".")
			else
				player:sendTextMessage(config.errorMsgType, "You don't have any active offers.".)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end

		-- !tradeoff info
		elseif word[1] == "info" then
			if not word[2] then
				player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to know about.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not isNumber(word[2]) then
				player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local offerID = tonumber(word[2])
			local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = "..offerID)

			if not queryResult then
				player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local playerID = result.getNumber(queryResult, "player_id")
			local tradeType = result.getNumber(queryResult, "type")
			local itemID = result.getNumber(queryResult, "item_id")
			local itemCount = result.getNumber(queryResult, "item_count")
			local itemCharges = result.getNumber(queryResult, "item_charges")
			local itemDuration = result.getNumber(queryResult, "item_duration")
			local itemName = result.getString(queryResult, "item_name")
			local isTrade = result.getNumber(queryResult, "item_trade")
			local cost = result.getDataLong(queryResult, "cost")
			local costCount = result.getNumber(queryResult, "cost_count")
			local addedDate = result.getDataLong(queryResult, "date")

			local normalItem = true
			local itemInfo = ItemType(itemID)
			local itemCount = (itemCount > 1 and itemCount or (itemInfo:getArticle() ~= "" and itemInfo:getArticle() or ""))
			local itemName = (itemCount > 1 and itemInfo:getPluralName() or itemInfo:getName())

			local itemDurationOrCharge = ""
			if itemDuration > 0 then
				normalItem = false
				itemDurationOrCharge = " with ".. getString(itemDuration) .." left" -- ???????????????????????????????????????????????????????????????????????
			elseif itemCharges > 0 then
				normalItem = false
				local plural = itemCharges > 1 and "s" or ""
				itemDurationOrCharge = " with ".. itemCharges .." charge".. plural .." left"			
			end

			local information = "[TRADE OFF] Information:\n"
			information = information .. "Offer: ".. itemCount .." "..itemName.. (normalItem and "" or (itemDurationOrCharge ~= "" and itemDurationOrCharge or ""))

			if itemInfo:isContainer() then
				local numItems = 0
				local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = "..offerID)
				if itemsInside ~= false then
					local itemsContainerMessage = "("
					while itemsInside ~= false do
						numItems = numItems + 1								
						local subID = result.getNumber(itemsInside, "item_id")
						local subCharges = result.getNumber(itemsInside, "item_charges")
						local subDuration = result.getNumber(itemsInside, "item_duration")
						local subCount = result.getNumber(itemsInside, "count")

						normalItem = true
						local subItemInfo = ItemType(subID)
						local subItemCount = (subCount > 1 and subCount or (subItemInfo:getArticle() ~= "" and subItemInfo:getArticle() or ""))
						local subItemName = (subCount > 1 and subItemInfo:getPluralName() or subItemInfo:getName())

						itemDurationOrCharge = ""
						if subDuration > 0 then
							normalItem = false
							itemDurationOrCharge = " with ".. getString(subDuration) .." left" -- ???????????????????????????????????????????????????????????????????????
						elseif subCharges > 0 then
							normalItem = false
							local plural = subCharges > 1 and "s" or ""
							itemDurationOrCharge = " with ".. subCharges .." charge".. plural .." left"			
						end

						if not result.next(itemsInside) then
							itemsContainerMessage = itemsContainerMessage .. subItemCount .. " " .. subItemName .. (normalItem and "" or (itemDurationOrCharge ~= "" and itemDurationOrCharge or "")) ..").\n"
							break
						else
							itemsContainerMessage = itemsContainerMessage .. subItemCount .. " " .. subItemName .. (normalItem and "" or (itemDurationOrCharge ~= "" and itemDurationOrCharge or "")) ..", "
						end
					end

					result.free(itemsInside)
					information = information .." with "..numItems.." items inside.\n"
					information = information ..itemsContainerMessage
				end
			else
				information = information ..".\n"
			end

			local tradeTypes = {[1] = "Item", [2] = "Container", [3] = "Trade"}
			local typeString = isTrade > 0 and tradeTypes[3] or tradeTypes[tradeType]
			
			if isTrade == 0 then -- dinheiro como pagamento
				information = information .. "Price: ".. cost .." gold coins.\n"
			else -- item como pagamento
				local costItemType = ItemType(cost)
				local costItemCount = (costCount > 1 and costCount or (costItemType:getArticle() ~= "" and costItemType:getArticle() or ""))
				local costItemName = (subCount > 1 and subItemInfo:getPluralName() or subItemInfo:getName())
				information = information .. "Price: ".. costItemCount .." ".. costItemName ..".\n"
			end

			information = information .. "Type: "..typeString..".\n"				
			information = information .. "Added: "..os.date("%d/%m/%Y at %X%p", addedDate)..".\n"

			local playerNameSellItem = Player(playerID):getName
			if playerNameSellItem then
				information = information .. "Added by: ".. playerNameSellItem..".\n"
			end

			result.free(queryResult)
			if config.infoOnPopUp then
				player:popupFYI(information)
			else
				player:sendTextMessage(config.infoMsgType, information)
			end

		-- !tradeoff buy
		elseif word[1] == "buy" then

			if not word[2] then
				player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to know about.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not isNumber(word[2]) then
				player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local offerID = tonumber(word[2])
			local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = ".. offerID)

			if not queryResult then
				player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			
			--if (word[2]) then
				-- !tradeoff buy, offerID
				--if isNumber(word[2]) and tonumber(word[2]) then
					--local offerID = tonumber(word[2])
					--local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = "..offerID)
					--if queryResult then
			
			local owner = result.getNumber(queryResult, "player_id")
			local playerGuid = player:getGuid()
			if playerGuid == owner then
				player:sendTextMessage(config.errorMsgType, "You can not buy your own offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local itemID = result.getNumber(queryResult, "item_id")
			local itemCount = result.getNumber(queryResult, "item_count")
			local itemCharges = result.getNumber(itemsInside, "item_charges")
			local itemDuration = result.getNumber(itemsInside, "item_duration")
			local isTrade = result.getNumber(queryResult, "item_trade")
			local cost = result.getNumber(queryResult, "cost")

			if isTrade > 0 then
				local itemCost = ItemType(cost)
				local ogCostCount
				local costCount = result.getNumber(queryResult, "cost_count")
				local itemCostName = (costCount > 1 and itemCost:getPluralName() or itemCost:getName())
				local itemCostCount = (costCount > 1 and costCount or (itemCost:getArticle() ~= "" and itemCost:getArticle() or ""))
				result.free(queryResult)

				if player:getItemCount(cost) < costCount then
					player:sendTextMessage(config.errorMsgType, "You don't have ".. itemCostCount .." ".. itemCostName .." to buy this offer.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				local itemCostCharges = itemCost:getAttribute(ITEM_ATTRIBUTE_CHARGES)
				local itemCostDuration = itemCost:getAttribute(ITEM_ATTRIBUTE_DURATION)

				if itemCostCharges or itemCostDuration then
					local itemSlotAmmo = player:getSlotItem(CONST_SLOT_AMMO)
					itemSlotAmmo = ItemType(itemSlotAmmo.uid)
					local itemSlotAmmoId = itemSlotAmmo:getId()

					if itemCostCharges > 0 or itemCostDuration > 0 then
						if itemCostCharges > 0 and itemSlotAmmoId == cost then
							local itemSlotAmmoCharges = itemSlotAmmo:getAttribute(ITEM_ATTRIBUTE_CHARGES)
							if itemSlotAmmoCharges ~= itemCostCharges then					
								player:sendTextMessage(config.errorMsgType, "The ".. itemCostName .." needs to be brand new.")
								player:getPosition():sendMagicEffect(CONST_ME_POFF)
								return false
							end

						elseif itemCostDuration > 0 and itemSlotAmmoId == cost then
							local itemSlotAmmoDuration = itemSlotAmmo:getAttribute(ITEM_ATTRIBUTE_DURATION)
							if itemSlotAmmoDuration ~= itemCostCharges then					
								player:sendTextMessage(config.errorMsgType, "The ".. itemCostName .." needs to be brand new.")
								player:getPosition():sendMagicEffect(CONST_ME_POFF)
								return false
							end
						else
							player:sendTextMessage(config.errorMsgType, "You need to put the "..itemCostName.." in your ammunition slot.")
							player:getPosition():sendMagicEffect(CONST_ME_POFF)
							return false
						end
					end
				end

				local ownerTownID						
								if isPlayerOnline(getPlayerNameByGUID(owner)) then								
									ownerTownID = getPlayerTown(getPlayerByGUID(owner))
									setPlayerStorageValue(getPlayerByGUID(owner), config.offerLimitStor, (tonumber(getPlayerStorageValue(getPlayerByGUID(owner), config.offerLimitStor))-1))
									doPlayerSendTextMessage(getPlayerByGUID(owner), config.successMsgType, "The player "..getPlayerName(cid).." just bought your offer with ID: "..offerID..", "..count.." "..itemCostName.." was sent to your "..getTownName(ownerTownID).." depot.")
								else
									local getTown = db.storeQuery("SELECT town_id FROM players WHERE id = "..owner)
									ownerTownID = result.getNumber(getTown, "town_id")
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
										local subID = result.getNumber(itemsInside, "item_id")
										local subCharges = result.getNumber(itemsInside, "item_charges")
										local subDuration = result.getNumber(itemsInside, "item_duration")
										local subCount = result.getNumber(itemsInside, "count")
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
			doPlayerSendTextMessage(cid, config.infoMsgType, config.helpMsg)
		end
	else
		doPlayerSendTextMessage(cid, config.infoMsgType, config.helpMsg)
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
