dofile('data/lib/custom/capturetheflag.lua')

IN ============= function Creature:onChangeOutfit(outfit)
	if self:isPlayer() then
		-- Capture the Flag event
		if self:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			self:sendCancelMessage("You can't change my outfit inside the event.")
			return false
		end
	end

IN ============= function Creature:onTargetCombat(target)

	-- Capture the Flag event
	if self:isPlayer() and target:isPlayer() then
		if self:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			if self:getStorageValue(CAPTURETHEFLAG.storage) == target:getStorageValue(CAPTURETHEFLAG.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end
	end
