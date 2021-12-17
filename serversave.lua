local savingEvent = 0

function onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local timeToSave = tonumber(param)
	if timeToSave then
			stopEvent(savingEvent)
			save(timeToSave * 60 * 1000)
		else
			saveServer()
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Server is saved ...")
		end
	end
end

function save(delay)
	saveServer()
	if delay > 0 then
		savingEvent = addEvent(save, delay, delay)
	end
end
