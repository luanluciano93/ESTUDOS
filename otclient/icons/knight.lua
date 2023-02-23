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
local spellUtito = "utito tempo"
local sayBlessing = "!holybless"

-----------------------   HEAL  --------------------------------

healMacro = macro(2, "HEAL", function()
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

-----------------------   UTITO TEMPO   --------------------------------

utitoTempoMacro = macro(1200, 'Utito Tempo', function()
	if hppercent() > lifeHealBot then
		if not hasPartyBuff() and not isInPz() then
			if manapercent() > manaHealBot then
				say(spellUtito)
				delay(10000)
			end
		end
	end
end)

iconUtito = addIcon("Utito Tempo", {item = 12246}, utitoTempoMacro)
iconUtito:breakAnchors()
iconUtito:move(310, 100)

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
iconFullAtk:move(280, 150)

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
iconAtk:move(210, 150)

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

expPotionMacro = macro(60000, 'Potion XP', function()
	if not isInPz() then
		use(itemIdExpPotion)
	end
end)

iconPotionXp = addIcon("Potion XP", {item = itemIdExpPotion}, expPotionMacro)
iconPotionXp:breakAnchors()
iconPotionXp:move(210, 240)

-----------------------	 STAMINA RESTORE	 --------------------------------

staminaRestoreMacro = macro(59000, "Stamina", function()
	if not isInPz() then
		use(11372)
	end
end)

iconStaminaRestore = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
iconStaminaRestore:breakAnchors()
iconStaminaRestore:move(260, 240)

-----------------------   EXP BOOSTER   --------------------------------

local boosterIdInative = 3997
local boosterIdAtive = 4010

expBoosterMacro = macro(58000, "Exp Booster", function()
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
	for i, tile in ipairs(g_map.getTiles(posz())) do
		for u, item in ipairs(tile:getItems()) do
			if table.find(corposQueUsamAKnife, item:getId()) then
				useWith(itemIdKnife, item)
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
	for i, tile in ipairs(g_map.getTiles(posz())) do
		for u, item in ipairs(tile:getItems()) do
			if table.find(corposQueUsamAStake, item:getId()) then
				useWith(itemIdStake, item)
			end
		end
	end
end)

iconStake = addIcon("BLESSED STAKE", {item = itemIdStake}, blessedStakeMacro)
iconStake:breakAnchors()
iconStake:move(260, 380)

-----------------------   PREY FREE  --------------------------------

preyFreeMacro = macro(60000, "Prey Free", function()
	if not isInPz() then
		say("!prey free, prey token, glooth golem")
	end
end)

iconPreyFree = addIcon("Prey Free", {item = 14086}, preyFreeMacro)
iconPreyFree:breakAnchors()
iconPreyFree:move(210, 500)

-----------------------   PREY VIP   --------------------------------

preyVipMacro = macro(63000, "Prey Vip", function()
	if not isInPz() then
		say("!prey vip, prey token, glooth golem")
	end
end)

iconPreyVip = addIcon("Prey Vip", {item = 14086}, preyVipMacro)
iconPreyVip:breakAnchors()
iconPreyVip:move(260, 500)

-----------------------   PREY DONATE   --------------------------------

preyDonateMacro = macro(66000, "Prey Donate", function()
	if not isInPz() then
		say("!prey donate, prey token, glooth golem")
	end
end)

iconPreyDonate = addIcon("Prey Donate", {item = 14086}, preyDonateMacro)
iconPreyDonate:breakAnchors()
iconPreyDonate:move(310, 500)

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
