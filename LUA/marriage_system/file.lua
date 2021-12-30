PROPOSED_STATUS = 1
MARRIED_STATUS = 2
PROPACCEPT_STATUS = 3
LOOK_MARRIAGE_DESCR = true
ITEM_WEDDING_RING = 2121
ITEM_ENGRAVED_WEDDING_RING = 10502

function Player.getSpouse(self)
	local playerId = self:getGuid()
    local resultId = db.storeQuery("SELECT `marriage_spouse` FROM `players` WHERE `id` = " .. playerId)
    if resultId ~= false then
        local spouseId = result.getNumber(resultId, "marriage_spouse")
        result.free(resultId)
        return spouseId
    end
    return false
end

function Player.setSpouse(self, spouseId)
	if not spouseId then
		return false
	end
	local playerId = self:getGuid()
    db.query("UPDATE `players` SET `marriage_spouse` = " .. spouseId .. " WHERE `id` = " .. playerId)
end

function Player.getMarriageStatus(self)
	local playerId = self:getGuid()
    local resultId = db.storeQuery("SELECT `marriage_status` FROM `players` WHERE `id` = " .. playerId)
    if resultId ~= false then
        local marriageStatus = result.getNumber(resultId, "marriage_status")
        result.free(resultId)
        return marriageStatus
    end
    return 0
end


function Player.setMarriageStatus(self, status)
	if not status then
		return false
	end
	local playerId = self:getGuid()
    db.query("UPDATE `players` SET `marriage_status` = " .. status .. " WHERE `id` = " .. playerId)
end

function Player:getMarriageDescription(self, thing)
    local descr = ""
    if thing:getMarriageStatus() == MARRIED_STATUS then
        local playerSpouse = thing:getSpouse()
        if self == thing then
            descr = descr .. " You are "
        elseif thing:getSex() == PLAYERSEX_FEMALE then
            descr = descr .. " She is "
        else
            descr = descr .. " He is "
        end
        descr = descr .. "married to " .. getPlayerNameById(playerSpouse) .. '.'
    end
    return descr
end

-- The following 2 functions can be used for delayed shouted text

function say(param)
selfSay(text)
doCreatureSay(param.cid, param.text, 1)
end

function delayedSay(text, delay)
local delay = delay or 0
local cid = getNpcCid()
addEvent(say, delay, {cid = cid, text = text})
end
----------------------------- data/scripts/eventcallbacks/player/default_onLook.lua

		if LOOK_MARRIAGE_DESCR and thing:isCreature() then
			if thing:isPlayer() then
				description = description .. self:getMarriageDescription(thing)
			end
		end
	
-- ALTER TABLE `players` ADD `marriage_status` tinyint(1) NOT NULL DEFAULT 0, ADD `marriage_spouse` int(11) NOT NULL DEFAULT -1
