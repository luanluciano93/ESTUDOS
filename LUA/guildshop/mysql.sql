ALTER TABLE `accounts` ADD `guild_points` INTEGER(11) NOT NULL DEFAULT '0';

ALTER TABLE `accounts` ADD `guild_points_stats` INT NOT NULL DEFAULT '0';

ALTER TABLE `guilds` ADD `last_execute_points` INT NOT NULL DEFAULT '0';

CREATE TABLE IF NOT EXISTS `z_shopguild_offer` (
	`id` int(11) NOT NULL auto_increment,
	`points` int(11) NOT NULL default '0',
	`itemid1` int(11) NOT NULL default '0',
	`count1` int(11) NOT NULL default '0',
	`iemid2` int(11) NOT NULL default '0',
	`count2` int(11) NOT NULL default '0',
	`offer_type` varchar(255) default NULL,
	`offer_description` text NOT NULL,
	`offer_name` varchar(255) NOT NULL,
	`pid` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`)
)

CREATE TABLE IF NOT EXISTS `z_shopguild_history_item` (
	`id` int(11) NOT NULL auto_increment,
	`to_name` varchar(255) NOT NULL default '0',
	`to_account` int(11) NOT NULL default '0',
	`from_nick` varchar(255) NOT NULL,
	`from_account` int(11) NOT NULL default '0',
	`price` int(11) NOT NULL default '0',
	`offer_id` int(11) NOT NULL default '0',
	`trans_state` varchar(255) NOT NULL,
	`trans_start` int(11) NOT NULL default '0',
	`trans_real` int(11) NOT NULL default '0',
	PRIMARY KEY (`id`)
)

CREATE TABLE IF NOT EXISTS `z_shopguild_history_pacc` (
	`id` int(11) NOT NULL auto_increment,
	`to_name` varchar(255) NOT NULL default '0',
	`to_account` int(11) NOT NULL default '0',
	`from_nick` varchar(255) NOT NULL,
	`from_account` int(11) NOT NULL default '0',
	`price` int(11) NOT NULL default '0',
	`pacc_days` int(11) NOT NULL default '0',
	`trans_state` varchar(255) NOT NULL,
	`trans_start` int(11) NOT NULL default '0',
	`trans_real` int(11) NOT NULL default '0',
	PRIMARY KEY (`id`)
) 

CREATE TABLE IF NOT EXISTS `z_ots_guildcomunication` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`type` varchar(255) NOT NULL,
	`action` varchar(255) NOT NULL,
	`param1` varchar(255) NOT NULL,
	`param2` varchar(255) NOT NULL,
	`param3` varchar(255) NOT NULL,
	`param4` varchar(255) NOT NULL,
	`param5` varchar(255) NOT NULL,
	`param6` varchar(255) NOT NULL,
	`param7` varchar(255) NOT NULL,
	`delete_it` int(2) NOT NULL DEFAULT '1',
	PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13107;
