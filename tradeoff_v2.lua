-- Trade Offline 2.0 by WooX --

local config = {
	aguardarStorage = 86421,
	levelParaAddOferta = 20,
	maxOfertasPorPlayer = 5,
	precoLimite = 2000000000, -- 2kkk
	goldItems = {
		2148,
		2152,
		2160
	},

	infoOnPopUp = true,
	infoMsgType = MESSAGE_STATUS_CONSOLE_BLUE,
	errorMsgType = MESSAGE_STATUS_CONSOLE_RED,
	successMsgType = MESSAGE_INFO_DESCR,
	helpMsg = "Enter the parameters (add, remove, active, buy, info).",
}

local config = {
	valuePerOffer = 500,
	blockedItems = {2165, 2152, 2148, 2160, 2166, 2167, 2168, 2169, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2343, 2433, 2640, 6132, 6300, 6301, 9932, 9933}
}

local function retornarItemsdoContainer(uid)
	local container = Container(uid)
	if not container then
		return false
	end

	if not container:isContainer() then
		return false
	end

	local itemsdoContainer = {}
	local tamanhoDoContainer = container:getSize()
	for i = (tamanhoDoContainer - 1), 0, -1 do
		local itemDentroDoContainer = container:getItem(i)
		if not itemDentroDoContainer then
			return false
		end

		-- Verifique se há recipientes com itens dentro
		local containerDentroDoContainer = Container(itemDentroDoContainer)
		if containerDentroDoContainer then
			if containerDentroDoContainer:isContainer() then
				local containerComItemDentroDoContainer = containerDentroDoContainer:getItem(0)
				if containerComItemDentroDoContainer then
					return false
				end
			end
		end

		local cargasDoItemDentroDoContainer = "DEFAULT"
		local duracaoDoItemDentroDoContainer = "DEFAULT"

		-- testar item:hasShowCharges()
		-- testar item:hasAttribute(ITEM_ATTRIBUTE_CHARGES)
		-- testar local charges = item:getCharges()
		local cargas = itemDentroDoContainer:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if cargas then
			if cargas > 0 then
				cargasDoItemDentroDoContainer = itemDentroDoContainer:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		-- testar item:hasShowDuration
		-- testar item:hasAttribute(ITEM_ATTRIBUTE_DURATION)
		-- testar local duration = item:getDuration() / 1000
		local duracao = itemDentroDoContainer:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if duracao then
			if duracao > 0 then
				duracaoDoItemDentroDoContainer = itemDentroDoContainer:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		local quantidadeDoItemDentroDoContainer = itemDentroDoContainer:isStackable() and itemDentroDoContainer:getCount() or 1

		local itemDentroDoContainerId = itemDentroDoContainer:getId()
		if not itemDentroDoContainerId then
			return false
		end

		itemsdoContainer[i + 1] = {id = itemDentroDoContainerId, count = quantidadeDoItemDentroDoContainer, charges = cargasDoItemDentroDoContainer, duration = duracaoDoItemDentroDoContainer}
	end
	return #itemsdoContainer > 0 and itemsdoContainer or false
end

function onSay(player, words, param)
	if param == '' then
		player:sendTextMessage(config.errorMsgType, "Command param required.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local posicao = player:getPosition()
	local tile = Tile(posicao)
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

	local aguardar = player:getStorageValue(config.aguardarStorage) - os.time()
	if aguardar > 0 then
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	texto = string.lower(param)
	local palavra = texto:splitTrimmed(",")

	player:setStorageValue(config.aguardarStorage, 10 + os.time())

	-- !tradeoff add
	if palavra[1] == "add" then

		if player:getLevel() < config.levelParaAddOferta then
			player:sendTextMessage(config.errorMsgType, "You don't have required level ".. config.levelParaAddOferta .." to add offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertas = 0
		local playerId = player:getGuid()
		local pesquisaBancoDeDados = db.storeQuery("SELECT `id` FROM `tradeoff` WHERE `player_id` = " .. playerId)
		if pesquisaBancoDeDados ~= false then
			repeat
				ofertas = ofertas + 1
			until not result.next(pesquisaBancoDeDados)
			result.free(pesquisaBancoDeDados)
		end

		if ofertas >= config.maxOfertasPorPlayer then
			player:sendTextMessage(config.errorMsgType, "Sorry you can't add more offers (max. " .. config.maxOfertasPorPlayer .. ")")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the value of the offer or the item you want to buy. Ex: !tradeoff add, sellForValue, !tradeoff add, sellForItem or !tradeoff add, sellForItem, sellForCountItem")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local item = player:getSlotItem(CONST_SLOT_AMMO)
		local itemOfertado = ItemType(item.uid)
		if not itemOfertado then
			player:sendTextMessage(config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemOfertadoId = itemOfertado:getId()
		if itemOfertadoId == 0 then
			player:sendTextMessage(config.errorMsgType, "To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not itemOfertado:isPickupable() then
			player:sendTextMessage(config.errorMsgType, "You cannot add this item type as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if itemOfertado:isCorpse() then
			player:sendTextMessage(config.errorMsgType, "You cannot add a corpse as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local mensagemPagamento = ""
		local itemComoPagamento = "DEFAULT"
		local addPagamento = "DEFAULT"
		local quantidadeDoItemComoPagamento = "DEFAULT"

		-- !tradeoff add, valor
		if isNumber(palavra[2]) then

			if table.contains(config.goldItems, itemOfertadoId) then
				player:sendTextMessage(config.errorMsgType, "You can't trade gold for gold.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local dinheiroComoPagamento = tonumber(palavra[2])
			if dinheiroComoPagamento < 1 then
				player:sendTextMessage(config.errorMsgType, "The offer must have a value greater than 0.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end			

			if dinheiroComoPagamento > config.precoLimite then
				player:sendTextMessage(config.errorMsgType, "The offer may not exceed the value of "..config.precoLimite.." gold coins.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			addPagamento = dinheiroComoPagamento
			mensagemPagamento = "for ".. dinheiroComoPagamento .." gold coins."

		else -- !tradeoff add, item

			local itemIdComoPagamento = ItemType(palavra[2]):getId()

			if not itemIdComoPagamento then
				player:sendTextMessage(config.errorMsgType, "This item does not exist, check if it's name is correct.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if table.contains(config.goldItems, itemIdComoPagamento) then
				player:sendTextMessage(config.errorMsgType, "To sell for gold insert only the amount instead of item name.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemIdComoPagamento == itemOfertadoId then
				player:sendTextMessage(config.errorMsgType, "You can not trade equal items.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemIdComoPagamento:isCorpse() then
				player:sendTextMessage(config.errorMsgType, "You can not buy a corpse.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not itemIdComoPagamento:isMoveable() or not itemIdComoPagamento:isPickupable() then
				player:sendTextMessage(config.errorMsgType, "You cannot request this type of payment item.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			-- !tradeoff add, item, count
			if palavra[3] then
				if not itemIdComoPagamento:isStackable() then
					player:sendTextMessage(config.errorMsgType, "You can only select the quantity with stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				if not isNumber(palavra[3]) then
					player:sendTextMessage(config.errorMsgType, "You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end	

				quantidadeDoItemComoPagamento = tonumber(palavra[3])
				if quantidadeDoItemComoPagamento < 1 or quantidadeDoItemComoPagamento > 100 then
					player:sendTextMessage(config.errorMsgType, "You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end

			itemComoPagamento = 1
			addPagamento = itemIdComoPagamento

			local artigoDoItemComoPagamento = (palavra[3] and quantidadeDoItemComoPagamento or (itemIdComoPagamento:getArticle() ~= "" and itemIdComoPagamento:getArticle() or ""))
			local nomeDoItemComoPagamento = (palavra[3] and quantidadeDoItemComoPagamento and itemIdComoPagamento:getPluralName() or itemIdComoPagamento:getName())
			mensagemPagamento = "for ".. artigoDoItemComoPagamento .. " ".. nomeDoItemComoPagamento .."."
		end

		local quantidadeDoItemOfertado = itemOfertado:isStackable() and itemOfertado:getCount() or 1
		local nomeDoItemOfertado = (quantidadeDoItemOfertado > 1 and itemOfertado:getPluralName() or itemOfertado:getName())

		local itemsDoContainer = retornarItemsdoContainer(item.uid)
		local tipoDeOferta = 1 -- no container
		if itemsDoContainer then
			tipoDeOferta = 2 -- container
		end

		local cargasDoItemOfertado = "DEFAULT"
		local duracaoDoItemOfertado = "DEFAULT"

		local cargas = itemOfertado:getAttribute(ITEM_ATTRIBUTE_CHARGES)
		if cargas then
			if cargas > 0 then
				cargasDoItemOfertado = itemOfertado:getAttribute(ITEM_ATTRIBUTE_CHARGES)
			end
		end

		local duracao = itemOfertado:getAttribute(ITEM_ATTRIBUTE_DURATION)
		if duracao then
			if duracao > 0 then
				duracaoDoItemOfertado = itemOfertado:getAttribute(ITEM_ATTRIBUTE_DURATION)
			end
		end

		local pesquisaBancoDeDados = "INSERT INTO trade_off_offers (id, player_id, type, item_id, item_count, item_charges, item_duration, item_name, item_trade, cost, cost_count, date) VALUES (NULL, "
			.. playerId ..", ".. tipoDeOferta ..", ".. itemOfertadoId ..", ".. quantidadeDoItemOfertado ..", ".. cargasDoItemOfertado ..", ".. duracaoDoItemOfertado ..", ".. nomeDoItemOfertado ..", ".. itemComoPagamento ..", " 
			.. addPagamento ..", ".. quantidadeDoItemComoPagamento ..", ".. os.time() ..")"

		local mensagemContainer = ""
		if tipoDeOferta == 2 then -- Container
			if not itemsDoContainer then
				player:sendTextMessage(config.errorMsgType, "You can not have containers with items inside the main container.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query(pesquisaBancoDeDados)

			for i = 1, #itemsDoContainer do
				db.query("INSERT INTO trade_off_container_items (offer_id, item_id, item_charges, item_duration, count) VALUES (LAST_INSERT_ID(), "
				..itemsDoContainer[i].id..", "..itemsDoContainer[i].charges..", "..itemsDoContainer[i].duration..", "..itemsDoContainer[i].count..")")
			end

			mensagemContainer = " with ".. #itemsDoContainer .." items inside"
		else
			db.query(pesquisaBancoDeDados)
		end

		local artigoDoItemOfertado = (quantidadeDoItemOfertado > 1 and quantidadeDoItemOfertado or (itemOfertado:getArticle() ~= "" and itemOfertado:getArticle() or ""))

		player:sendTextMessage(config.successMsgType, "You announced ".. artigoDoItemOfertado .. " ".. nomeDoItemOfertado .."".. mensagemContainer .." "
		.. mensagemPagamento .." Check out the offer id on the website.")

		itemOfertado:remove(1)

	-- !tradeoff remove
	elseif palavra[1] == "remove" then
		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to remove.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end	
		
		-- !tradeoff remove, offerID
		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local ofertaBancoDeDados = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = ".. ofertaID)
		if not ofertaBancoDeDados then
			player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerIdBancoDeDados = result.getNumber(ofertaBancoDeDados, "player_id")
		local playerId = player:getGuid()

		if playerId ~= playerIdBancoDeDados then
			player:sendTextMessage(config.errorMsgType, "You can not remove someone else's offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local parcel = Game.createItem(ITEM_PARCEL)
		local itemID = result.getNumber(ofertaBancoDeDados, "item_id")
		local cidadeId = Town(player:getTown():getId())	
		local depot = player:getDepotChest(cidadeId, true)
		if not depot then
			player:sendTextMessage(config.errorMsgType, "The city you live in has no depot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if ItemType(itemID):isContainer() then
			local container = Game.createItem(itemID)
			local selecionarItensDentroDoContainer = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
			if selecionarItensDentroDoContainer ~= false then
				repeat
					local idDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_id")
					local cargasDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_charges")
					local duracaoDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_duration")
					local quantidadeDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "count")

					local itemDentroDoContainer
					if duracaoDoItemDentroDoContainer > 0 then
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
						itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItemDentroDoContainer)
					elseif cargasDoItemDentroDoContainer > 0 then
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
						itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_CHARGES, cargasDoItemDentroDoContainer)
					else
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer, quantidadeDoItemDentroDoContainer)
					end

					container:addItemEx(Item(itemDentroDoContainer))

				until not result.next(selecionarItensDentroDoContainer)
				result.free(selecionarItensDentroDoContainer)

				db.query("DELETE FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
			end

			parcel:addItemEx(Item(container))

		else
			local quantidadeDoItem = result.getNumber(ofertaBancoDeDados, "item_count")
			local cargasDoItem = result.getNumber(ofertaBancoDeDados, "item_charges")
			local duracaoDoItem = result.getNumber(ofertaBancoDeDados, "item_duration")								

			local item			
			if duracaoDoItem > 0 then
				item = Game.createItem(itemID)
				item:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItem)
			elseif cargasDoItem > 0 then
				item = Game.createItem(itemID)
				item:setAttribute(ITEM_ATTRIBUTE_DURATION, cargasDoItem)
			else
				item = Game.createItem(itemID, quantidadeDoItem)
			end

			parcel:addItemEx(Item(item))
		end

		result.free(ofertaBancoDeDados)
		db.query("DELETE FROM trade_off_offers WHERE id = ".. ofertaID)

		local cidadeNome = cidadeId:getName()
		local carta = Game.createItem(2598)
		carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "You canceled your offer with ID: ".. ofertaID ..".")
		parcel:addItemEx(Item(carta))
		depot:addItemEx(parcel)

		player:sendTextMessage(config.successMsgType, "You canceled your offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. cidadeNome .." depot.")

		return false

	-- !tradeoff active
	elseif palavra[1] == "active" then
		local playerId = player:getGuid()
		local selecionarOfertasNoBancoDeDados = db.storeQuery("SELECT * FROM trade_off_offers WHERE player_id = ".. playerId)
		if selecionarOfertasNoBancoDeDados ~= false then
			local mensagemOfertas = ""
			while selecionarOfertasNoBancoDeDados ~= false do
				local ofertaID = result.getNumber(selecionarOfertasNoBancoDeDados, "id")
				if not result.next(selecionarOfertasNoBancoDeDados) then
					mensagemOfertas = mensagemOfertas .. ofertaID
					break
				else
					mensagemOfertas = mensagemOfertas .. ofertaID.. ", "
				end
			end
			result.free(selecionarOfertasNoBancoDeDados)
			player:sendTextMessage(config.successMsgType, "Active offers ID: ".. mensagemOfertas ..".")
		else
			player:sendTextMessage(config.errorMsgType, "You don't have any active offers.".)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end

		return false

	-- !tradeoff info
	elseif palavra[1] == "info" then
		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to know about.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local selecionarOfertas = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = ".. ofertaID)
		if not selecionarOfertas then
			player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerID = result.getNumber(selecionarOfertas, "player_id")
		local tipoDeOferta = result.getNumber(selecionarOfertas, "type")
		local itemID = result.getNumber(selecionarOfertas, "item_id")
		local itemCount = result.getNumber(selecionarOfertas, "item_count")
		local itemCharges = result.getNumber(selecionarOfertas, "item_charges")
		local itemDuration = result.getNumber(selecionarOfertas, "item_duration")
		local itemName = result.getString(selecionarOfertas, "item_name")
		local isTrade = result.getNumber(selecionarOfertas, "item_trade")
		local cost = result.getDataLong(selecionarOfertas, "cost")
		local costCount = result.getNumber(selecionarOfertas, "cost_count")
		local addedDate = result.getDataLong(selecionarOfertas, "date")
		result.free(selecionarOfertas)

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
			local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
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
		local typeString = isTrade > 0 and tradeTypes[3] or tradeTypes[tipoDeOferta]

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

		if config.infoOnPopUp then
			player:popupFYI(information)
		else
			player:sendTextMessage(config.infoMsgType, information)
		end

		return false

	-- !tradeoff buy
	elseif palavra[1] == "buy" then

		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "Please enter the offerID you want to know about.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local queryResult = db.storeQuery("SELECT * FROM trade_off_offers WHERE id = ".. ofertaID)

		if not queryResult then
			player:sendTextMessage(config.errorMsgType, "Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local owner = result.getNumber(queryResult, "player_id")
		local vendedor = Player(owner)
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
		local playerName = player:getName()

		if isTrade > 0 then
			local itemCost = ItemType(cost)
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

			local cidadeId = Town(vendedor:getTown():getId())
			local cidadeNome = cidadeId:getName()

			local parcel = Game.createItem(ITEM_PARCEL)
			local carta = Game.createItem(2598)
			carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "You sold your offer with ID: ".. ofertaID ..".")
			parcel:addItemEx(Item(carta))
			parcel:addItem(cost, costCount)
			local depot = vendedor:getDepotChest(cidadeId, true)

			if depot and player:removeItem(cost, costCount) then
				depot:addItemEx(parcel)
				vendedor:sendTextMessage(config.successMsgType, "The player ".. playerName .." just bought your offer with ID: ".. ofertaID ..", ".. itemCostCount .." "
				.. itemCostName .." was sent to your ".. cidadeNome .." depot.")
			end

		else
			if player:getTotalMoney() < cost then
				player:sendTextMessage(config.errorMsgType, "You don't have enough money to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			else
				local cidadeId = Town(vendedor:getTown():getId())
				local depot = vendedor:getDepotChest(cidadeId, true)
				if player:transferMoneyTo(vendedor, cost) and depot then
					local carta = Game.createItem(2598)
					carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "The player ".. playerName .." just bought your offer with ID: ".. ofertaID ..", ".. cost .." gold coins were transfered to your bank account.")
					depot:addItemEx(carta)
					vendedor:sendTextMessage(config.successMsgType, "The player ".. playerName .." just bought your offer with ID: ".. ofertaID ..", ".. cost .." gold coins were transfered to your bank account.")
				else
					player:sendTextMessage(config.errorMsgType, "You don't have enough money to buy this offer.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end
		end
	
		local parcel = Game.createItem(ITEM_PARCEL)
		if ItemType(itemID):isContainer() then
			local itemRemove = Game.createItem(itemID)
			local itemsInside = db.storeQuery("SELECT * FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
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

				until not result.next(itemsInside)
				result.free(itemsInside)
				
				db.query("DELETE FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
			end

			parcel:addItemEx(Item(itemRemove))

		else
			local itemCount = result.getNumber(queryResult, "item_count")
			local itemCharges = result.getNumber(itemsInside, "item_charges")
			local itemDuration = result.getNumber(itemsInside, "item_duration")								

			local item
			if itemDuration > 0 then
				item = Game.createItem(itemID)
				item:setAttribute(ITEM_ATTRIBUTE_DURATION, itemDuration)
			elseif itemCharges > 0 then
				item = Game.createItem(itemID, itemCharges)
			else
				item = Game.createItem(itemID, itemCount)
			end

			parcel:addItemEx(Item(item))
		end

		result.free(queryResult)
		db.query("DELETE FROM trade_off_offers WHERE id = ".. ofertaID)

		local townId = Town(player:getTown():getId())	
		local townName = townId:getName()
		local letter = Game.createItem(2598)
		letter:setAttribute(ITEM_ATTRIBUTE_TEXT, "You bought the offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. townName .." depot.")
		parcel:addItemEx(Item(letter))
		local depot = player:getDepotChest(townId, true)
		if depot then
			depot:addItemEx(parcel)
			player:sendTextMessage(config.successMsgType, "You bought the offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. townName .." depot.")
		end

		return false

	else
		doPlayerSendTextMessage(cid, config.infoMsgType, config.helpMsg)
	end

	return false
end
