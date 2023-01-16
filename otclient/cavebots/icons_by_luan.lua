-----------------------   AUTO SD   --------------------------------

autoSDMacro = macro(1000, "SD", function()
	if hppercent() > 90 and manapercent() > 80 then
		local target = g_game.getAttackingCreature()
		if target then
			local sd = findItem(3155)
			if sd then
				g_game.useWith(sd, target)
			end
		end
	end
end)

icon1 = addIcon("SD", {item = 3155}, autoSDMacro)
icon1:breakAnchors()
icon1:move(260, 100)
icon1:setText("100")

-----------------------   ANTI-PUSH   --------------------------------

local dropItems = {
	3035,
	3031
}

local maxStackedItems = 10

gpAntiPushDrop = macro(150 , "anti push", function ()
	antiPush()
end)

onPlayerPositionChange(function()
	antiPush()
end)

function antiPush()
	if gpAntiPushDrop:isOff() then
		return
	end

	local tile = g_map.getTile(pos())
	if tile and tile:getThingCount() < maxStackedItems then
		local thing = tile:getTopThing()
		if thing and not thing:isNotMoveable() then
			for i, item in pairs(dropItems) do
				if item ~= thing:getId() then
					local dropItem = findItem(item)
					if dropItem then
						g_game.move(dropItem, pos(), 1)
					end
				end
			end
		end
	end
end

icon2 = addIcon("anti push", {item = 3035}, gpAntiPushDrop)
icon2:breakAnchors()
icon2:move(210, 400)
icon2:setText("100")

-----------------------   UTITO TEMPO   --------------------------------

utitoTempoMacro = macro(3000, 'Utito Tempo', function()
	if hppercent() > 70 then
		if not hasPartyBuff() and not isInPz() then
			if manapercent() > 75 then
				say('utito tempo')
			end
		end
	end
end)

icon3 = addIcon("Utito Tempo", {item = 12246}, utitoTempoMacro)
icon3:breakAnchors()
icon3:move(260, 200)
icon3:setText("100")

-----------------------   POTION EXP   --------------------------------

expPotionMacro = macro(30000, 'Potion XP', function()
	if hppercent() > 70 then
		local item = findItem(11980)
		if item and g_game.isAttacking() then
			use(11980)
		end
	end
end)

icon4 = addIcon("Potion XP", {item = 11980}, expPotionMacro)
icon4:breakAnchors()
icon4:move(210, 300)
icon4:setText("100")

-----------------------   EK ATTACK   --------------------------------

ekAttackMacro = macro(1000, "EK ATTACK", function()
	if hppercent() > 70 then
		if manapercent() > 75 and g_game.isAttacking() then
			if getMonsters(1) > 1 then
				say("exori gran")
			else
				say("exori hur")
			end
		end
	end
end)

icon5 = addIcon("EK ATK", {item = 11951}, ekAttackMacro)
icon5:breakAnchors()
icon5:move(310, 200)
icon5:setText("100")

-----------------------   STAMINA RESTORE   --------------------------------

local horas = 40

staminaRestoreMacro = macro(30000, "Stamina", function()
	if hppercent() > 70 then
		if not isInPz() and stamina() < (horas * 60) then
			use(11372)
		end
	end
end)

icon6 = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
icon6:breakAnchors()
icon6:move(260, 300)
icon6:setText("100")

-----------------------   EXP BOOSTER   --------------------------------

expBoosterMacro = macro(30000, "Exp Booster", function()
	if hppercent() > 70 then
		local boosterIdInative = 3997
		local boosterIdAtive = 4010
		local ativado = findItem(boosterIdAtive)
		if not ativado and not isInPz() and g_game.isAttacking() then
			use(boosterIdInative)
		end
	end
end)

icon7 = addIcon("Exp Booster", {item = 3997}, expBoosterMacro)
icon7:breakAnchors()
icon7:move(310, 300)
icon7:setText("100")

-----------------------   HEAL MAGE   --------------------------------

local minPercentHP = 90
local minPercentMANA = 85

healMageMacro = macro(100, "HEAL MAGE", function()
	if hppercent() < minPercentHP then
		say("exura vita")
	else
		if manapercent() < minPercentMANA then
			g_game.useInventoryItemWith(3162, player)
		end
	end
end)

icon8 = addIcon("HEAL MAGE", {item = 3162}, healMageMacro)
icon8:breakAnchors()
icon8:move(210, 100)
icon8:setText("100")

-----------------------   HEAL EK   --------------------------------

local ekMinPercentHP = 70
local ekMinPercentMANA = 90

healEkMacro = macro(100, "HEAL EK", function()
	if hppercent() < ekMinPercentHP then
		g_game.useInventoryItemWith(3163, player)
	else
		if manapercent() < ekMinPercentMANA then
			g_game.useInventoryItemWith(3163, player)
		end
	end
end)

icon9 = addIcon("HEAL EK", {item = 3163}, healEkMacro)
icon9:breakAnchors()
icon9:move(210, 200)
icon9:setText("100")

-----------------------   ED ATTACK   --------------------------------

edAttackMacro = macro(1000, "ED ATTACK", function()
	if hppercent() > 90 then
		if manapercent() > 75 and g_game.isAttacking() then
			say("demonic pox")
		end
	end
end)

icon10 = addIcon("ED ATK", {item = 13501}, edAttackMacro)
icon10:breakAnchors()
icon10:move(310, 100)
icon10:setText("100")

-----------------------   OBSIDIAN KNIFE   --------------------------------

local itemIdKnife = 5908
local corposQueUsamAKnife = {3090, 5969, 2871, 5982, 2866, 5981, 2876, 5983, 4259, 6040, 4262, 6041, 4256, 4251, 11285, 11288, 11277, 11280, 11280, 11269, 11272, 11281, 11284, 3104, 5973, 2881, 5984, 2931, 5999, 3031, 6030, 11343}

obsidianKnifeMacro = macro(500, "OB. KNIFE", function()
	if hppercent() > 50 then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAKnife, item:getId()) then
					useWith(itemIdKnife, item)
				end
			end
		end
	end
end)

icon11 = addIcon("OB. KNIFE", {item = itemIdKnife}, obsidianKnifeMacro)
icon11:breakAnchors()
icon11:move(210, 500)
icon11:setText("100")

-----------------------   BLESSED WOODEN STAKE   --------------------------------

local itemIdStake = 5942
local corposQueUsamAStake = {2916, 5995, 2956, 6006, 9654, 9660}

blessedStakeMacro = macro(500, "BLESSED STAKE", function()
	if hppercent() > 50 then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAStake, item:getId()) then
					useWith(itemIdStake, item)
				end
			end
		end
	end
end)

icon12 = addIcon("BLESSED STAKE", {item = itemIdStake}, blessedStakeMacro)
icon12:breakAnchors()
icon12:move(260, 500)
icon12:setText("100")
