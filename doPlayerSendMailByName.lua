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
