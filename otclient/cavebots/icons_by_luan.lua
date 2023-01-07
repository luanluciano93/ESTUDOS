-----------------------   AUTO SD   --------------------------------

autoSDMacro = macro(200, "SD", function()
	local target = g_game.getAttackingCreature()
	if target then
		local sd = findItem(3155)
		if sd then
			g_game.useWith(sd, target)
		end
	end
end)

icon1 = addIcon("SD", {item =3155}, autoSDMacro)
icon1:breakAnchors()
icon1:move(210, 100)
icon1:setText("100")

-----------------------   ANTI-PUSH   --------------------------------

local dropItems = {
	3035,
	3031
}

local maxStackedItems = 10

gpAntiPushDrop = macro(100 , "anti push", function ()
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

utitoTempoMacro = macro(100, 'Utito Tempo', function()
	if not hasPartyBuff() and not isInPz() then
		say('utito tempo')
	end
end)

icon3 = addIcon("Utito Tempo", {item = 12246}, utitoTempoMacro)
icon3:breakAnchors()
icon3:move(210, 200)
icon3:setText("100")

-----------------------   POTION EXP   --------------------------------

expPotionMacro = macro(10000, 'Potion XP', function()
	local item = findItem(11980)
	if item and g_game.isAttacking() then
		use(11980)
	end
end)

icon4 = addIcon("Potion XP", {item = 11980}, expPotionMacro)
icon4:breakAnchors()
icon4:move(210, 300)
icon4:setText("100")

-----------------------   EK ATTACK   --------------------------------

ekAttackMacro = macro(1000, "EK ATTACK", function()
	if g_game.isAttacking() then
		if getMonsters(1) > 2 then
			say("exori gran")
		else
			say("exori hur")
		end
	end
end)

icon5 = addIcon("EK ATK", {item = 11951}, ekAttackMacro)
icon5:breakAnchors()
icon5:move(260, 200)
icon5:setText("100")

-----------------------   STAMINA RESTORE   --------------------------------

local horas = 40

staminaRestoreMacro = macro(30000, "Stamina", function()
	if not isInPz() and stamina() < (horas * 60) then
		use(11588)
	end
end)

icon6 = addIcon("Stamina", {item = 11372}, staminaRestoreMacro)
icon6:breakAnchors()
icon6:move(260, 300)
icon6:setText("100")

-----------------------   EXP BOOSTER   --------------------------------

expBoosterMacro = macro(10000, "Exp Booster", function()
	local boosterIdInative = 3997
	local boosterIdAtive = 4010
	local ativado = findItem(boosterIdAtive)
	if not ativado and not isInPz() and g_game.isAttacking() then
		use(boosterIdInative)
	end
end)

icon7 = addIcon("Exp Booster", {item = 3997}, expBoosterMacro)
icon7:breakAnchors()
icon7:move(310, 300)
icon7:setText("100")
