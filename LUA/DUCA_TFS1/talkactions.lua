-- <talkaction words="/duca" script="duca.lua" />

dofile('data/lib/custom/duca.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if duca_totalPlayers() == 0 then
			eventsOutfit = {}
			duca_teleportCheck()
		else
			player:sendCancelMessage("Duca event is already running.")
		end
	end
	return false
end
