-- configure o heal do seu char ...
-- se for MAGE, indico a deixar 90 de life e 80 de mana (baseado na holy mana rune)
-- se for EK, indico a deixar 70 de life e 85 de mana (baseado na holy life rune)

local lifeHealBot = 90
local manaHealBot = 80

-----------------------	 HEAL MAGE	 --------------------------------

healMageMacro = macro(100, "HEAL MAGE", function()
	if hppercent() < lifeHealBot then
		say("exura vita")
	else
		if manapercent() < manaHealBot then
			g_game.useInventoryItemWith(3162, player)
		end
	end
end)

icon1 = addIcon("HEAL MAGE", {item = 3162}, healMageMacro)
icon1:breakAnchors()
icon1:move(210, 100)

-----------------------	 AUTO SD	 --------------------------------

local itemIdSd = 3155

autoSDMacro = macro(1000, "SD", function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot then
		local target = g_game.getAttackingCreature()
		local sd = findItem(itemIdSd)
		if target and sd then
			g_game.useWith(sd, target)
		end
	end
end)

icon2 = addIcon("SD", {item = itemIdSd}, autoSDMacro)
icon2:breakAnchors()
icon2:move(260, 100)

-----------------------	 ED ATTACK FULL	--------------------------------

edAttackFullMacro = macro(500, "ED ATTACK FULL", function()
	if hppercent() > lifeHealBot then
		if manapercent() > manaHealBot then
			say("demonic pox")
		end
	end
end)

icon3 = addIcon("ED ATTACK FULL", {text = "Demonic FULL"}, edAttackFullMacro)
icon3:breakAnchors()
icon3:move(280, 150)

-----------------------	 ED ATTACK TARGET	--------------------------------

edAttackMacro = macro(1000, "ED ATTACK TARGET", function()
	if edAttackFullMacro.isOn() then return true end
	if hppercent() > lifeHealBot then
		if manapercent() > manaHealBot and g_game.isAttacking() then
			say("demonic pox")
		end
	end
end)

icon4 = addIcon("ED ATK TARGET", {text = "Demonic Target"}, edAttackMacro)
icon4:breakAnchors()
icon4:move(210, 150)

-----------------------	 ANTI-PUSH	 --------------------------------

local dropItems = {
	3035,
	3031
}

local maxStackedItems = 10

gpAntiPushDrop = macro(200 , "anti push", function ()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot then
		antiPush()
	end
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

icon5 = addIcon("anti push", {item = 3035, hotkey = "INSERT"}, gpAntiPushDrop)
icon5:breakAnchors()
icon5:move(210, 310)

-----------------------	 POTION EXP	 --------------------------------

local itemIdExpPotion = 11980

expPotionMacro = macro(30000, 'Potion XP', function()
	if hppercent() > lifeHealBot then
		if not isInPz() then
			use(itemIdExpPotion)
		end
	end
end)

icon6 = addIcon("Potion XP", {item = itemIdExpPotion}, expPotionMacro)
icon6:breakAnchors()
icon6:move(210, 240)

-----------------------	 STAMINA RESTORE	 --------------------------------

local horas = 40

staminaRestoreMacro = macro(30000, "Stamina", function()
	if hppercent() > lifeHealBot then
		if not isInPz() and stamina() < (horas * 60) then
			use(11372)
		end
	end
end)

icon7 = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
icon7:breakAnchors()
icon7:move(260, 240)

-----------------------	 EXP BOOSTER	 --------------------------------

expBoosterMacro = macro(30000, "Exp Booster", function()
	if hppercent() > lifeHealBot then
		local boosterIdInative = 3997
		local boosterIdAtive = 4010
		local ativado = findItem(boosterIdAtive)
		if not ativado and not isInPz() then
			use(boosterIdInative)
		end
	end
end)

icon8 = addIcon("Exp Booster", {item = 3997}, expBoosterMacro)
icon8:breakAnchors()
icon8:move(310, 240)

-----------------------	 OBSIDIAN KNIFE	 --------------------------------

local itemIdKnife = 5908
local corposQueUsamAKnife = {3090, 5969, 2871, 5982, 2866, 5981, 2876, 5983, 4259, 6040, 4262, 6041, 4256, 4251, 11285, 11288, 11277, 11280, 11280, 11269, 11272, 11281, 11284, 3104, 5973, 2881, 5984, 2931, 5999, 3031, 6030, 11343}

obsidianKnifeMacro = macro(500, "OB. KNIFE", function()
	if hppercent() > lifeHealBot then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAKnife, item:getId()) then
					useWith(itemIdKnife, item)
				end
			end
		end
	end
end)

icon9 = addIcon("OB. KNIFE", {item = itemIdKnife}, obsidianKnifeMacro)
icon9:breakAnchors()
icon9:move(210, 380)

-----------------------	 BLESSED WOODEN STAKE	 --------------------------------

local itemIdStake = 5942
local corposQueUsamAStake = {2916, 5995, 2956, 6006, 9654, 9660}

blessedStakeMacro = macro(500, "BLESSED STAKE", function()
	if hppercent() > lifeHealBot then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAStake, item:getId()) then
					useWith(itemIdStake, item)
				end
			end
		end
	end
end)

icon10 = addIcon("BLESSED STAKE", {item = itemIdStake}, blessedStakeMacro)
icon10:breakAnchors()
icon10:move(260, 380)

------------------------------------
