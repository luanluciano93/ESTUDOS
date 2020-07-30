
dofile('data/lib/custom/safezone.lua')

IN ============= function Creature:onChangeOutfit(outfit)
	if self:isPlayer() then
		-- Battlefield event
		if self:getStorageValue(AFEZONE.storage) > 0 then
			self:sendCancelMessage("You can't change my outfit inside the event.")
			return false
		end
	end
