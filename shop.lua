-- <talkaction words="!shop" script="znoteshop.lua"/>
-- Znote Shop v1.1 for Znote AAC on TFS 1.2+

function onSay(player, words, param)

	local storage = Storage.znoteShop -- Make sure to select non-used storage. This is used to prevent SQL load attacks.
	local cooldown = 15 -- in seconds.

	if player:getStorageValue(storage) > os.time() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Can only be executed once every " .. cooldown .. " seconds. Remaining cooldown: " .. player:getStorageValue(storage) - os.time() .. ".")
		return false
	end

	player:setStorageValue(storage, os.time() + cooldown)

	print("Player: " .. player:getName() .. " triggered !shop talkaction.")
	
	-- Create the query
	local orderQuery = db.storeQuery("SELECT `id`, `type`, `itemid`, `count` FROM `znote_shop_orders` WHERE `account_id` = " .. player:getAccountId() .. ";")
	local served = false 

	-- Detect if we got any results
	if orderQuery ~= false then
		repeat
			-- Fetch order values
			local offer_id = result.getNumber(orderQuery, "id")
			local offer_type = result.getNumber(orderQuery, "type")
			local offer_itemid = result.getNumber(orderQuery, "itemid")
			local offer_count = result.getNumber(orderQuery, "count")

			local description = "Unknown or custom type"
			local type_desc = {
				"itemids",
				"pending premium (skip)",
				"pending gender change (skip)",
				"pending character name change (skip)",
				"Outfit and addons",
				"Mounts",
				"Instant house purchase"
			}

			local descriptionTable = type_desc[offer_type]
			if descriptionTable then 
				description = descriptionTable
			end

			print("Processing type "..offer_type..": ".. description)

			-- ORDER TYPE 1 (Regular item shop products)
			if offer_type == 1 or offer_type == 7 or offer_type == 8 or offer_type == 9 or offer_type == 10 then
				served = true
				-- Get weight
				local itemType = ItemType(offer_itemid)
				local itemWeight = itemType:getWeight(offer_count)
				local playerCap = player:getFreeCapacity()
				if playerCap < itemWeight then
					player:sendTextMessage(MESSAGE_STATUS_WARNING, 'You have found a ' .. offer_count .. 'x ' .. itemType:getName() .. ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				db.query("DELETE FROM `znote_shop_orders` WHERE `id` = " .. offer_id .. ";")
				local item = player:addItem(offer_itemid, offer_count)
				item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Purchased by ".. player:getName())
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations! You have received " .. offer_count .. " x " .. ItemType(offer_itemid):getName() .. "!")
			end

			-- ORDER TYPE 5 (Outfit and addon)
			if offer_type == 5 then
				served = true

				local itemid = offer_itemid
				local outfits = {}

				if itemid > 1000 then
					local first = math.floor(itemid / 1000)
					table.insert(outfits, first)
					itemid = itemid - (first * 1000)
				end

				table.insert(outfits, itemid)

				for _, outfitId in pairs(outfits) do
					-- Make sure player don't already have this outfit and addon
					if player:hasOutfit(outfitId, offer_count) then
						player:sendTextMessage(MESSAGE_STATUS_WARNING, "You already have this outfit and addon!")
						return false
					end

					db.query("DELETE FROM `znote_shop_orders` WHERE `id` = " .. offer_id .. ";")
					player:addOutfit(outfitId)
					player:addOutfitAddon(outfitId, offer_count)
					player:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations! You have received a new outfit!")
				end
			end

			-- ORDER TYPE 6 (Mounts)
			if offer_type == 6 then
				served = true
				-- Make sure player don't already have this outfit and addon
				if player:hasMount(offer_itemid) then
					player:sendTextMessage(MESSAGE_STATUS_WARNING, "You already have this mount!")
					return false
				end				
				
				db.query("DELETE FROM `znote_shop_orders` WHERE `id` = " .. offer_id .. ";")
				player:addMount(offer_itemid)
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations! You have received a new mount!")
			end

			-- Add custom order types here
			-- Type 1 is for itemids (Already coded here)
			-- Type 2 is for premium (Coded on web)
			-- Type 3 is for gender change (Coded on web)
			-- Type 4 is for character name change (Coded on web)
			-- Type 5 is for character outfit and addon (Already coded here)
			-- Type 6 is for mounts (Already coded here)
			-- So use type 8+ for custom stuff, like etc packages.
			-- if offer_type == 8 then
			-- end

		until not result.next(orderQuery)
		result.free(orderQuery)
		
		if not served then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have no orders to process in-game.")
		end

	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have no orders.")
	end

	return false
end
