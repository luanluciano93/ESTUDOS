function onAdvance(player, skill, oldLevel, newLevel)

	if newLevel <= oldLevel then
		return true
	end

	local skills = {
		[0] = "+Fist UP!", -- SKILL_FIST
		[1] = "+Club UP!", -- SKILL_CLUB
		[2] = "+Sword UP!", -- SKILL_SWORD
		[3] = "+Axe UP!", -- SKILL_AXE
		[4] = "+Distance UP!", -- SKILL_DISTANCE
		[5] = "+Shield UP!", -- SKILL_SHIELD
		[6] = "+Fishing UP!", -- SKILL_FISHING
		[7] = "+Magic UP!", -- SKILL_MAGLEVEL
		[8] = "+Level UP!" -- SKILL_LEVEL
	}

	local upSkill = skills[skill]
	if upSkill then
		if skill == SKILL_LEVEL then
			player:addHealth(player:getMaxHealth())
			player:addMana(player:getMaxMana())
		end
		player:say(upSkill[1], TALKTYPE_ORANGE_1)
		player:getPosition():sendMagicEffect(math.random(CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_BLUE))	
		player:save()
	end	

	return true
end
