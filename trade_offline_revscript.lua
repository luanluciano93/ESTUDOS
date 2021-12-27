-- Auto install tables if we dont got them yet (first install)
db.query([[
	CREATE TABLE IF NOT EXISTS `trade_off_offers` (
		`id` int unsigned NOT NULL AUTO_INCREMENT,
		`player_id` int NOT NULL,
		`type` tinyint NOT NULL DEFAULT '0',
		`item_id` smallint unsigned NOT NULL,
		`item_count` smallint unsigned NOT NULL DEFAULT '1',
		`item_charges` int unsigned NOT NULL DEFAULT '0',
		`item_duration` int unsigned NOT NULL DEFAULT '0',
		`item_name` varchar(255) NOT NULL,
		`item_trade` tinyint NOT NULL DEFAULT '0',
		`cost` bigint unsigned NOT NULL,
		`cost_count` int unsigned NOT NULL DEFAULT '1',
		`date` bigint unsigned NOT NULL,
		PRIMARY KEY (`id`),
		FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
	
	CREATE TABLE `trade_off_container_items` (
		`offer_id` int unsigned NOT NULL,
		`item_id` smallint unsigned NOT NULL,
		`item_charges` int unsigned NOT NULL DEFAULT '0',
		`item_duration` int unsigned NOT NULL DEFAULT '0', 
		`count` smallint unsigned NOT NULL DEFAULT '1',
		FOREIGN KEY (`offer_id`) REFERENCES `trade_off_offers`(`id`) ON DELETE CASCADE,
		KEY `offer_id`(`offer_id`)
	) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
]])

-- Auto populate table if it is empty
local resultId = db.storeQuery("SELECT `id` FROM `player_history_skill` LIMIT 1;")
if resultId == false then
	db.asyncQuery([[
		INSERT INTO `player_history_skill` (
			`player_id`,
			`lastlogin`, 
			`lastlogout`, 
			`town_id`,
			`lastip`,
			`skull`,
			`blessings`,
			`onlinetime`,
			`balance`, 
			`level`, 
			`experience`, 
			`maglevel`, 
			`skill_fist`, 
			`skill_club`, 
			`skill_sword`, 
			`skill_axe`, 
			`skill_dist`, 
			`skill_shielding`, 
			`skill_fishing`
		)
		SELECT 
			`p`.`id` AS `player_id`, 
			`zp`.`created` AS `lastlogin`, 
			CASE WHEN `p`.`lastlogout` > 0 
				THEN `p`.`lastlogout` 
				ELSE `zp`.`created` 
			END AS `lastlogout`, 
			`p`.`town_id`,
			`p`.`lastip`,
			`p`.`skull`,
			`p`.`blessings`,
			`p`.`onlinetime`,
			`p`.`balance`, 
			`p`.`level`, 
			`p`.`experience`, 
			`p`.`maglevel`, 
			`p`.`skill_fist`, 
			`p`.`skill_club`, 
			`p`.`skill_sword`, 
			`p`.`skill_axe`, 
			`p`.`skill_dist`, 
			`p`.`skill_shielding`, 
			`p`.`skill_fishing` 
		FROM `players` AS `p`
		INNER JOIN `znote_players` AS `zp`
			ON `p`.`id` = `zp`.`player_id`
		ORDER BY `zp`.`created`
	]])
else
	result.free(resultId)
end

-- Logout event, triggered by logout, and death
function historyLogoutEvent(player)
	local blessdec = 0
	local i = 0
	while player:hasBlessing(i+1) do
		blessdec = blessdec+2^i
		i = i+1
	end

	local playerGuid = player:getGuid()
	db.query([[
		INSERT INTO `player_history_skill` (
			`player_id`,
			`lastlogin`, 
			`lastlogout`, 
			`town_id`,
			`lastip`,
			`skull`,
			`blessings`,
			`onlinetime`,
			`balance`, 
			`level`, 
			`experience`, 
			`maglevel`, 
			`skill_fist`, 
			`skill_club`, 
			`skill_sword`, 
			`skill_axe`, 
			`skill_dist`, 
			`skill_shielding`, 
			`skill_fishing`
		) VALUES (
			]]..table.concat({
				playerGuid,
				player:getLastLoginSaved(),
				os.time(),
				player:getTown():getId(),
				player:getIp(),
				player:getSkull(),
				blessdec,
				"(SELECT `onlinetime` FROM `players` WHERE `id`='"..playerGuid.."') + ".. os.time() - player:getLastLoginSaved(),
				player:getBankBalance(),
				player:getLevel(),
				player:getExperience(),
				player:getMagicLevel(),
				player:getSkillLevel(SKILL_FIST),
				player:getSkillLevel(SKILL_CLUB),
				player:getSkillLevel(SKILL_SWORD),
				player:getSkillLevel(SKILL_AXE),
				player:getSkillLevel(SKILL_DISTANCE),
				player:getSkillLevel(SKILL_SHIELD),
				player:getSkillLevel(SKILL_FISHING)
			}, ",")..[[
		);
	]])
end

-- Log player state on logout
local player_history_skill = CreatureEvent("player_history_skill")
function player_history_skill.onLogout(player)
	--print("2-logout["..player:getName().."]")
	historyLogoutEvent(player)
	return true
end
player_history_skill:register()

-- And on death
local player_history_skill_death = CreatureEvent("player_history_skill_death")
function player_history_skill_death.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	--print("3-death["..creature:getName().."]")
	historyLogoutEvent(Player(creature))
end
player_history_skill_death:register()

-- If this is first login, insert current progress
local player_history_skill_login = CreatureEvent("player_history_skill_login")
function player_history_skill_login.onLogin(player)
	--print("1-login["..player:getName().."]")
	player:registerEvent("player_history_skill_death")

	local playerGuid = player:getGuid()
	local resultId = db.storeQuery("SELECT `id` FROM `player_history_skill` WHERE `player_id`="..playerGuid.." LIMIT 1;")
	if resultId == false then
		db.query([[
			INSERT INTO `player_history_skill` (
				`player_id`,
				`lastlogin`, 
				`lastlogout`, 
				`town_id`,
				`lastip`,
				`skull`,
				`blessings`,
				`onlinetime`,
				`balance`, 
				`level`, 
				`experience`, 
				`maglevel`, 
				`skill_fist`, 
				`skill_club`, 
				`skill_sword`, 
				`skill_axe`, 
				`skill_dist`, 
				`skill_shielding`, 
				`skill_fishing`
			)
			SELECT 
				`p`.`id` AS `player_id`, 
				`zp`.`created` AS `lastlogin`, 
				CASE WHEN `p`.`lastlogout` > 0 
					THEN `p`.`lastlogout` 
					ELSE `zp`.`created` 
				END AS `lastlogout`, 
				`p`.`town_id`,
				`p`.`lastip`,
				`p`.`skull`,
				`p`.`blessings`,
				`p`.`onlinetime`,
				`p`.`balance`, 
				`p`.`level`, 
				`p`.`experience`, 
				`p`.`maglevel`, 
				`p`.`skill_fist`, 
				`p`.`skill_club`, 
				`p`.`skill_sword`, 
				`p`.`skill_axe`, 
				`p`.`skill_dist`, 
				`p`.`skill_shielding`, 
				`p`.`skill_fishing` 
			FROM `players` AS `p`
			INNER JOIN `znote_players` AS `zp`
				ON `p`.`id` = `zp`.`player_id`
			WHERE `p`.`id` = ]]..playerGuid..[[
		]])
	else
		result.free(resultId)
	end
	return true
end
player_history_skill_login:register()
