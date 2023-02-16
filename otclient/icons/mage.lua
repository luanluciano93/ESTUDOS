-- configure o heal do seu char ...
-- se for MAGE, indico a deixar 90 de life e 80 de mana (baseado na holy mana rune)
-- se for EK, indico a deixar 70 de life e 85 de mana (baseado na holy life rune)

local lifeHealBot = 80
local manaHealBot = 85
local safeUtamo = true
local lowLifeUseUtamo = 15
local lowManaRemoveUtamo = 10
local isDruid = true
local spellHeal = "exura vita" -- exura vita
local runeHeal = 3162 -- holy life rune (lvl 400)
local spellAttack = "demonic pox" -- (lvl 800)
local itemIdExpPotion = 11980
local spellHaste = "utani gran hur"
local sayBlessing = "!holybless"

-----------------------   UTAMO VITA   --------------------------------

utamoVita = macro(100, "UTAMO VITA", function()
	if not hasManaShield() then
		say("utamo vita")
	end
end)

iconUtamo = addIcon("UTAMO VITA", {item = 11830}, utamoVita)
iconUtamo:breakAnchors()
iconUtamo:move(310, 100)

-----------------------   HEAL  --------------------------------

healMacro = macro(2, "HEAL", function()
	if hppercent() < lifeHealBot then
		if safeUtamo and utamoVita.isOff() and hppercent() < lowLifeUseUtamo and manapercent() > lowManaRemoveUtamo and not hasManaShield() then
			say("utamo vita")
		else
			if isDruid then
				say('exura sio "' .. player:getName())
			else
				say(spellHeal)
			end
		end
	end

	if manapercent() < manaHealBot then
		if safeUtamo and utamoVita.isOff() and manapercent() < lowManaRemoveUtamo and hasManaShield() then
			say("exana vita")
		end
		g_game.useInventoryItemWith(runeHeal, player)
	elseif safeUtamo and utamoVita.isOff() and manapercent() > manaHealBot and hasManaShield() then
		say("exana vita")
	end
end)

iconHeal = addIcon("HEAL", {item = runeHeal}, healMacro)
iconHeal:breakAnchors()
iconHeal:move(210, 100)

-----------------------   HASTE   --------------------------------

haste = macro(500, "HASTE", function()
	if (hppercent() > lifeHealBot and not hasHaste()) or isParalyzed() then
		say(spellHaste)
	end
end)

iconHaste = addIcon("HASTE", {item = 3079}, haste)
iconHaste:breakAnchors()
iconHaste:move(260, 100)

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

iconSd = addIcon("SD", {item = itemIdSd}, autoSDMacro)
iconSd:breakAnchors()
iconSd:move(210, 170)

-----------------------	 ATTACK FULL	--------------------------------

attackFullMacro = macro(500, "ATTACK FULL", function()
	if hppercent() > lifeHealBot and not isInPz() then
		if manapercent() > manaHealBot then
			say(spellAttack)
		end
	end
end)

iconFullAtk = addIcon("ATTACK FULL", {text = "Atk FULL"}, attackFullMacro)
iconFullAtk:breakAnchors()
iconFullAtk:move(320, 150)

-----------------------	 ATTACK TARGET	--------------------------------

attackMacro = macro(1000, "ATTACK TARGET", function()
	if attackFullMacro.isOn() then
		return true
	end
	if hppercent() > lifeHealBot and not isInPz() then
		if manapercent() > manaHealBot and g_game.isAttacking() then
			say(spellAttack)
		end
	end
end)

iconAtk = addIcon("ATK TARGET", {text = "Atk Target"}, attackMacro)
iconAtk:breakAnchors()
iconAtk:move(260, 150)

-----------------------	 ANTI-PUSH	--------------------------------

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

iconAntiPush = addIcon("anti push", {item = 3035, hotkey = "INSERT"}, gpAntiPushDrop)
iconAntiPush:breakAnchors()
iconAntiPush:move(210, 310)

-----------------------	 FULL PARALIZE RUNE	 --------------------------------

local paralizeRuneId = 3165

paralizeRuneMacro = macro(1500, 'Full Paralize Rune', function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot and not isInPz() then
		local target = g_game.getAttackingCreature()
		if target then
			useWith(paralizeRuneId, target)
		end
	end
end)

iconParalizeRune = addIcon("Full Paralize Rune", {item = paralizeRuneId}, paralizeRuneMacro)
iconParalizeRune:breakAnchors()
iconParalizeRune:move(260, 440)

-----------------------   FULL FIRE BOMB   --------------------------------

local fireBombRuneId = 3192

fireBombMacro = macro(1000, 'Full Fire Bomb', function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot and not isInPz() then
		useWith(fireBombRuneId, player)
	end
end)

iconFireBomb = addIcon("Full Fire Bomb", {item = fireBombRuneId}, fireBombMacro)
iconFireBomb:breakAnchors()
iconFireBomb:move(210, 440)

-----------------------   POTION EXP   --------------------------------

expPotionMacro = macro(10000, 'Potion XP', function()
	if not isInPz() then
		use(itemIdExpPotion)
	end
end)

iconPotionXp = addIcon("Potion XP", {item = itemIdExpPotion}, expPotionMacro)
iconPotionXp:breakAnchors()
iconPotionXp:move(210, 240)

-----------------------	 STAMINA RESTORE	 --------------------------------

local horas = 40

staminaRestoreMacro = macro(10000, "Stamina", function()
	if not isInPz() then
		if stamina() < (horas * 60) then
			use(11372)
		end
	end
end)

iconStaminaRestore = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
iconStaminaRestore:breakAnchors()
iconStaminaRestore:move(260, 240)

-----------------------   EXP BOOSTER   --------------------------------

local boosterIdInative = 3997
local boosterIdAtive = 4010

expBoosterMacro = macro(10000, "Exp Booster", function()
	if not isInPz() then
		local ativado = findItem(boosterIdAtive)
		if not ativado then
			use(boosterIdInative)
		end
	end
end)

iconBooster = addIcon("Exp Booster", {item = boosterIdInative}, expBoosterMacro)
iconBooster:breakAnchors()
iconBooster:move(310, 240)

-----------------------	 OBSIDIAN KNIFE	 --------------------------------

local itemIdKnife = 5908
local corposQueUsamAKnife = {3090, 5969, 2871, 5982, 2866, 5981, 2876, 5983, 4259, 6040, 4262, 6041, 4256, 4251, 11285, 11288, 11277, 11280, 11280, 11269, 11272, 11281, 11284, 3104, 5973, 2881, 5984, 2931, 5999, 3031, 6030, 11343}

obsidianKnifeMacro = macro(500, "OB. KNIFE", function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAKnife, item:getId()) then
					useWith(itemIdKnife, item)
				end
			end
		end
	end
end)

iconKnife = addIcon("OB. KNIFE", {item = itemIdKnife}, obsidianKnifeMacro)
iconKnife:breakAnchors()
iconKnife:move(210, 380)

-----------------------	 BLESSED WOODEN STAKE	 --------------------------------

local itemIdStake = 5942
local corposQueUsamAStake = {2916, 5995, 2956, 6006, 9654, 9660}

blessedStakeMacro = macro(500, "BLESSED STAKE", function()
	if hppercent() > lifeHealBot and manapercent() > manaHealBot then
		for i, tile in ipairs(g_map.getTiles(posz())) do
			for u, item in ipairs(tile:getItems()) do
				if table.find(corposQueUsamAStake, item:getId()) then
					useWith(itemIdStake, item)
				end
			end
		end
	end
end)

iconStake = addIcon("BLESSED STAKE", {item = itemIdStake}, blessedStakeMacro)
iconStake:breakAnchors()
iconStake:move(260, 380)

-----------------------------------------------------------------------------

buybless = macro(5000, "Bless", function()
	if isInPz() then
		say(sayBlessing)
	end
	onTextMessage(function(mode, text)
		if string.find(text, "You already have all") then
			buybless.setOff(isOn)
		end
	end)
end)

macro(5000, function()
    if not isInPz() then
        buybless.setOn(isOff)
    end
end)
