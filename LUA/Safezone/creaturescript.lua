-- <event type="login" name="Safezone-Login" script="events/safezone.lua"/>
-- <event type="logout" name="Safezone-Logout" script="events/safezone.lua"/>

function onLogin(player)
	if player:getStorageValue(Storage.safezoneEvent) > 0 then
		player:setStorageValue(Storage.safezoneEvent, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(Storage.safezoneEvent) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end
