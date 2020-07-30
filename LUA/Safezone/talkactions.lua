-- <talkaction words="/safezone" script="safezone.lua" />

dofile('data/lib/custom/safezone.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if safezone_totalPlayers() == 0 then
			eventsOutfit = {}
			safezone_teleportCheck()
		else
			player:sendCancelMessage("Safezone event is already running.")
		end
	end
	return false
end
