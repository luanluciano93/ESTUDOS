dofile('data/lib/custom/duca.lua')

IN ============= function Creature:onChangeOutfit(outfit)
	if self:isPlayer() then
		-- Duca event
		if self:getStorageValue(DUCA.storage) > 0 then
			self:sendCancelMessage("You can't change my outfit inside the event.")
			return false
		end
	end

IN ============= function Creature:onTargetCombat(target)

	-- Duca event
	if self:isPlayer() and target:isPlayer() then
		if self:getStorageValue(DUCA.storage) > 0 then
			if self:getStorageValue(DUCA.storage) == target:getStorageValue(DUCA.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end
	end
