local combat = Combat()
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_MAGICWALL)

dofile('data/lib/custom/zombie.lua')

function onCastSpell(creature, variant, isHotkey)
	-- Zombie event
	if creature:getStorageValue(ZOMBIE.storage) > 0 then
		creature:sendCancelMessage("You cannot use this rune in the event.")
		return false
	end

	return combat:execute(creature, variant)
end
