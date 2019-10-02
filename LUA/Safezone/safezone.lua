SAFEZONE = {
	teleportTimeClose = 1,
	positionTeleportOpen = Position(972, 964, 7),
	positionEnterEvent = Position(972, 964, 7),
	storage = 9999,
	actionId = 8614,
	protectionTileId = 2343,
	levelMin = 10,
	maxPlayers = 20,
	reward = {2160, 10},
	lifeColor = {
		[1] = 94, -- red
		[2] = 77, -- orange
		[3] = 79 -- yellow
	},
	positionEvent = {firstTile = {x = 972, y = 964, z = 7}, tilesX = 10, tilesY = 10}
}

function safezoneTeleportCheck()
	local tile = Tile(SAFEZONE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			local totalPlayers = safezoneTotalPlayers()
			if totalPlayers > 0 then
				Game.broadcastMessage("The safeZone event will begin now with ".. totalPlayers .." participants.!", MESSAGE_STATUS_WARNING)
				print("> SafeZone Event will begin now [".. totalPlayers .."].")
				
				createProtectionTiles()
			else
				print("> SafeZone Event ended up not having the participation of players.")
			end
		else
			Game.broadcastMessage("The safeZone event was opened and will close in ".. SAFEZONE.teleportTimeClose .." minutes.", MESSAGE_STATUS_WARNING)

			local teleport = Game.createItem(1387, 1, SAFEZONE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(SAFEZONE.actionId)
			end

			addEvent(safezoneTeleportCheck, SAFEZONE.teleportTimeClose * 60000)
		end
	end
end

function safezoneTotalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			x = x + 1
		end
	end
	return x
end

local function totalProtectionTile()
	local totalPlayers = safezoneTotalPlayers()
	if totalPlayers >= 5 then
		return totalPlayers - 3
	else
		return totalPlayers - 1
	end
end

local function createProtectionTiles()
	if safezoneTotalPlayers() == 1 then
		for _, player in ipairs(Game.getPlayers()) do
			if player:getStorageValue(SAFEZONE.storage) > 0 then
				player:setStorageValue(SAFEZONE.storage, 0)
				player:teleportTo(player:getTown():getTemplePosition())
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

				local itemType = ItemType(SAFEZONE.reward[1])
				if itemType:getId() ~= 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. SAFEZONE.reward[2] .." ".. itemType:getName() .. " as a reward for first place in the safezone event.")
					player:addItem(itemType:getId(), SAFEZONE.reward[2])
				end

				Game.broadcastMessage("SafeZone Event is finish. Congratulation to the player ".. player:getName() .." for being the event champion!", MESSAGE_STATUS_WARNING)
			end
		end

	elseif safezoneTotalPlayers() > 1 then
		local createTiles, totalTiles = 0, totalProtectionTile()
		local tileX = SAFEZONE.positionEvent.firstTile.x
		local tileY = SAFEZONE.positionEvent.firstTile.y
		local tileZ = SAFEZONE.positionEvent.firstTile.z
		local tilesX = SAFEZONE.positionEvent.tilesX
		local tilesY = SAFEZONE.positionEvent.tilesY
		local protectionTileId = SAFEZONE.protectionTileId
		while createTiles < totalTiles do
			local randomX = math.random(tileX, tileX + tilesX)
			local randomY = math.random(tileY, tileY + tilesY)
			local newPosition = Position({x = randomX, y = randomY, z = tileZ})
			local tile = Tile(newPosition)
			if tile then
				local item = tile:getItemById(protectionTileId)
				if not item then
					local tileProtection = Game.createItem(protectionTileId, 1, newPosition)
					if tileProtection then
						tileProtection:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
						addEvent(deleteProtectionTiles, 5000, newPosition, protectionTileId)
						createTiles = createTiles + 1
					end
				end
			end
		end
		addEvent(checkPlayersinProtectionTiles, 4000)
		addEvent(createProtectionTiles, 6000)
	end
end

local function deleteProtectionTiles(position, tileId)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(tileId)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			item:remove()
		end
	end
end

local function checkPlayersinProtectionTiles()
	local protectionTileId = SAFEZONE.protectionTileId
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			local item = Tile(player:getPosition()):getItemById(protectionTileId)
			if not item then
				if player:getStorageValue(SAFEZONE.storage) > 1 then
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
					player:setStorageValue(SAFEZONE.storage, player:getStorageValue(SAFEZONE.storage) - 1)
					local lifeColor = SAFEZONE.lifeColor[player:getStorageValue(SAFEZONE.storage)]
					player:setOutfit({lookHead = lifeColor, lookBody = lifeColor, lookLegs = lifeColor, lookFeet = lifeColor})
				else
					player:setStorageValue(SAFEZONE.storage, 0)
					player:getPosition():sendMagicEffect(CONST_ME_SMALLPLANTS)
					player:teleportTo(player:getTown():getTemplePosition())
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				end
			end
		end
	end
end
