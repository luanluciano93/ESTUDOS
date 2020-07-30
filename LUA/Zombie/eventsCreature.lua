  
dofile('data/lib/custom/zombie.lua')

IN ============= function Creature:onTargetCombat(target)

	-- Zombie event
	if self:isPlayer() and target:isPlayer() then
		if self:getStorageValue(ZOMBIE.storage) > 0 then
			if self:getStorageValue(ZOMBIE.storage) == target:getStorageValue(ZOMBIE.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end
	end
