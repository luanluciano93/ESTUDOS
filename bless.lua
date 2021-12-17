function onSay(player, words, param)

	if not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendCancelMessage("To buy bless you need to be in protection zone.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local bless = 5
	local allBless = 0
	for i = 1, bless do
		if player:hasBlessing(i) then
			allBless = allBless + 1
		end
	end

	if allBless == bless then
		player:sendCancelMessage("You already have all blessings.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:removeTotalMoney(50000) then
		for i = 1, bless do
			player:addBlessing(i)
		end

		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have been blessed by the gods!")
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
	else
		player:sendCancelMessage("You don't have 50000 gold coints to buy bless.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end
