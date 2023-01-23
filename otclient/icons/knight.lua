-- configure o heal do seu char ...
-- se for MAGE, indico a deixar 90 de life e 80 de mana (baseado na holy mana rune)
-- se for EK, indico a deixar 70 de life e 85 de mana (baseado na holy life rune)

local lifeHealBot = 70
local manaHealBot = 85
local spellHeal = "exura gran ico" -- exura gran ico (lvl 600)
local runeHeal = 3163 -- holy life rune (lvl 400)
local spellAttack = "dead exori" -- (lvl 800)
local itemIdExpPotion = 11980
local spellHaste = "utani hur"

-----------------------   HEAL EK   --------------------------------

healEkMacro = macro(1, "HEAL EK", function()
	if hppercent() < lifeHealBot then
		g_game.useInventoryItemWith(runeHeal, player)
		if manapercent() > manaHealBot then
			say(spellHeal)
		end
	else
		if manapercent() < manaHealBot then
			g_game.useInventoryItemWith(runeHeal, player)
		end
	end
end)

icon1 = addIcon("HEAL EK", {item = runeHeal}, healEkMacro)
icon1:breakAnchors()
icon1:move(210, 200)
icon1:setText("100")

-----------------------   HASTE   --------------------------------

haste = macro(500, "HASTE", function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot and not hasHaste() then
		say(spellHaste)
		delay(5000)
	end
end)

icon2 = addIcon("HASTE", {item = 3079}, haste)
icon2:breakAnchors()
icon2:move(210, 200)
icon2:setText("100")

-----------------------   EK ATTACK   --------------------------------

ekAttackMacro = macro(1000, "EK ATTACK", function()
	if hppercent() > lifeHealBot then
		if manapercent() > manaHealBot and g_game.isAttacking() then
			--if getMonsters(1) > 1 then
				say(spellAttack)
			--else
				--say("exori hur")
			--end
		end
	end
end)

icon3 = addIcon("EK ATK", {item = 11951}, ekAttackMacro)
icon3:breakAnchors()
icon3:move(310, 200)
icon3:setText("100")

-----------------------   UTITO TEMPO   --------------------------------

utitoTempoMacro = macro(1000, 'Utito Tempo', function()
	if hppercent() > lifeHealBot then
		if not hasPartyBuff() and not isInPz() then
			if manapercent() > manaHealBot then
				say('utito tempo')
				delay(10000)
			end
		end
	end
end)

icon4 = addIcon("Utito Tempo", {item = 12246}, utitoTempoMacro)
icon4:breakAnchors()
icon4:move(260, 200)
icon4:setText("100")

-----------------------   ANTI-PUSH   --------------------------------

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

icon5 = addIcon("anti push", {item = 3035}, gpAntiPushDrop)
icon5:breakAnchors()
icon5:move(210, 400)
icon5:setText("100")

-----------------------   POTION EXP   --------------------------------

expPotionMacro = macro(10000, 'Potion XP', function()
	if hppercent() > lifeHealBot then
		if not isInPz() then
			use(itemIdExpPotion)
		end
	end
end)

icon6 = addIcon("Potion XP", {item = itemIdExpPotion}, expPotionMacro)
icon6:breakAnchors()
icon6:move(210, 300)
icon6:setText("100")

-----------------------   STAMINA RESTORE   --------------------------------

local horas = 40

staminaRestoreMacro = macro(10000, "Stamina", function()
	if hppercent() > lifeHealBot then
		if not isInPz() and stamina() < (horas * 60) then
			use(11372)
		end
	end
end)

icon7 = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
icon7:breakAnchors()
icon7:move(260, 300)
icon7:setText("100")

-----------------------   EXP BOOSTER   --------------------------------

local boosterIdInative = 3997
local boosterIdAtive = 4010

expBoosterMacro = macro(10000, "Exp Booster", function()
	if hppercent() > lifeHealBot then
		local ativado = findItem(boosterIdAtive)
		if not ativado and not isInPz() then
			use(boosterIdInative)
		end
	end
end)

icon8 = addIcon("Exp Booster", {item = boosterIdInative}, expBoosterMacro)
icon8:breakAnchors()
icon8:move(310, 300)
icon8:setText("100")

-----------------------   OBSIDIAN KNIFE   --------------------------------

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
icon9:move(210, 500)
icon9:setText("100")

-----------------------   BLESSED WOODEN STAKE   --------------------------------

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
icon10:move(260, 500)
icon10:setText("100")
