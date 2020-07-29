-- <talkaction words="/battlefield" script="battlefield.lua" />

dofile('data/lib/custom/battlefield.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if battlefield_totalPlayers() == 0 then
			eventsOutfit = {}
			battlefield_teleportCheck()
		else
			player:sendCancelMessage("Battlefield event is already running.")
		end
	end
	return false
end
