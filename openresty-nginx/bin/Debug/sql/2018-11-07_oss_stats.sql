/*
Navicat MySQL Data Transfer

Source Server         : local
Source Server Version : 50505
Source Host           : 127.0.0.1:3306
Source Database       : sandbox

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2018-06-28 21:27:28
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for _oss_stats_retention
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_retention`;
CREATE TABLE `_oss_stats_retention` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `accumulate_user` int(11) NOT NULL COMMENT '累积用户总数',
  `online_users` int(11) NOT NULL COMMENT '在线用户总数',
  `new_user` int(11) NOT NULL COMMENT '新用户数',
  `retention_1` int(11) NOT NULL COMMENT '次日留存数',
  `new_user_retention_1` int(11) NOT NULL COMMENT '次日留存数（新增）',
  `retention_3` int(11) NOT NULL COMMENT '3日留存数',
  `new_user_retention_3` int(11) NOT NULL COMMENT '3日留存数（新增）',
  `retention_7` int(11) NOT NULL COMMENT '7日留存数',
  `new_user_retention_7` int(11) NOT NULL COMMENT '7日留存数（新增）',
  `retention_30` int(11) NOT NULL COMMENT '30日留存数',
  `new_user_retention_30` int(11) NOT NULL COMMENT '30日留存数（新增）',

  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Procedure structure for __oss_do_stats_retention
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_retention`;

CREATE PROCEDURE `__oss_do_stats_retention`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	DECLARE p_date_1 datetime DEFAULT 0;
	DECLARE p_date_3 datetime DEFAULT 0;
	DECLARE p_date_7 datetime DEFAULT 0;
	DECLARE p_date_30 datetime DEFAULT 0;

	SET p_date = DATE(p_day);
	SET p_date_1 = DATE_SUB(p_date,INTERVAL 1 DAY);
	SET p_date_3 = DATE_SUB(p_date,INTERVAL 3 DAY);
	SET p_date_7 = DATE_SUB(p_date,INTERVAL 7 DAY);
	SET p_date_30 = DATE_SUB(p_date,INTERVAL 30 DAY);

	-- 
	INSERT INTO _oss_stats_retention(`day`, `accumulate_user`)
		SELECT p_date AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE DATE(createtime) <= p_date
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- 
	INSERT INTO _oss_stats_retention(`day`, `online_users`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- 
	INSERT INTO _oss_stats_retention(`day`, `new_user`)
		SELECT p_date AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE DATE(createtime) = p_date
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);


	-- p_date_1
	INSERT INTO _oss_stats_retention(`day`, `accumulate_user`)
		SELECT p_date_1 AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE DATE(createtime) <= p_date_1
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- p_date_1
	INSERT INTO _oss_stats_retention(`day`, `online_users`)
		SELECT p_date_1 AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date_1 AND DATE_ADD(p_date_1,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- p_date_1
	INSERT INTO _oss_stats_retention(`day`, `new_user`)
		SELECT p_date_1 AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE DATE(createtime) = p_date_1
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);

	-- retention_1
	INSERT INTO _oss_stats_retention(`day`, `retention_1`)
		(SELECT p_date_1 AS `day`, COUNT(DISTINCT(t1.userid)) AS `retention_1` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date_1 AND DATE_ADD(p_date_1,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `retention_1` = VALUES(`retention_1`);

	-- new_user_retention_1
	INSERT INTO _oss_stats_retention(`day`, `new_user_retention_1`)
		(SELECT p_date_1 AS `day`, COUNT(DISTINCT(t1.userid)) AS `new_user_retention_1` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE DATE(gate_account.createtime) = p_date_1
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `new_user_retention_1` = VALUES(`new_user_retention_1`);


	-- p_date_3
	INSERT INTO _oss_stats_retention(`day`, `accumulate_user`)
		SELECT p_date_3 AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE DATE(createtime) <= p_date_3
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- p_date_3
	INSERT INTO _oss_stats_retention(`day`, `online_users`)
		SELECT p_date_3 AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date_3 AND DATE_ADD(p_date_3,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- p_date_3
	INSERT INTO _oss_stats_retention(`day`, `new_user`)
		SELECT p_date_3 AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE DATE(createtime) = p_date_3
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);

	-- retention_3
	INSERT INTO _oss_stats_retention(`day`, `retention_3`)
		(SELECT p_date_3 AS `day`, COUNT(DISTINCT(t1.userid)) AS `retention_3` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date_3 AND DATE_ADD(p_date_3,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `retention_3` = VALUES(`retention_3`);

	-- new_user_retention_3
	INSERT INTO _oss_stats_retention(`day`, `new_user_retention_3`)
		(SELECT p_date_3 AS `day`, COUNT(DISTINCT(t1.userid)) AS `new_user_retention_3` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE DATE(gate_account.createtime) = p_date_3
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `new_user_retention_3` = VALUES(`new_user_retention_3`);


	-- p_date_7
	INSERT INTO _oss_stats_retention(`day`, `accumulate_user`)
		SELECT p_date_7 AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE DATE(createtime) <= p_date_7
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- p_date_7
	INSERT INTO _oss_stats_retention(`day`, `online_users`)
		SELECT p_date_7 AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date_7 AND DATE_ADD(p_date_7,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- p_date_7
	INSERT INTO _oss_stats_retention(`day`, `new_user`)
		SELECT p_date_7 AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE DATE(createtime) = p_date_7
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);

	-- retention_7
	INSERT INTO _oss_stats_retention(`day`, `retention_7`)
		(SELECT p_date_7 AS `day`, COUNT(DISTINCT(t1.userid)) AS `retention_7` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date_7 AND DATE_ADD(p_date_7,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `retention_7` = VALUES(`retention_7`);

	-- new_user_retention_7
	INSERT INTO _oss_stats_retention(`day`, `new_user_retention_7`)
		(SELECT p_date_7 AS `day`, COUNT(DISTINCT(t1.userid)) AS `new_user_retention_7` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE DATE(gate_account.createtime) = p_date_7
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `new_user_retention_7` = VALUES(`new_user_retention_7`);


	-- p_date_30
	INSERT INTO _oss_stats_retention(`day`, `accumulate_user`)
		SELECT p_date_30 AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE DATE(createtime) <= p_date_30
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- p_date_30
	INSERT INTO _oss_stats_retention(`day`, `online_users`)
		SELECT p_date_30 AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date_30 AND DATE_ADD(p_date_30,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- p_date_30
	INSERT INTO _oss_stats_retention(`day`, `new_user`)
		SELECT p_date_30 AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE DATE(createtime) = p_date_30
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);

	-- retention_30
	INSERT INTO _oss_stats_retention(`day`, `retention_30`)
		(SELECT p_date_30 AS `day`, COUNT(DISTINCT(t1.userid)) AS `retention_30` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date_30 AND DATE_ADD(p_date_30,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `retention_30` = VALUES(`retention_30`);

    -- new_user_retention_30
	INSERT INTO _oss_stats_retention(`day`, `new_user_retention_30`)
		(SELECT p_date_30 AS `day`, COUNT(DISTINCT(t1.userid)) AS `new_user_retention_30` 
		    FROM (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE gate_log_online.action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY) 
											AND gate_account.userid = gate_log_online.userid) AS t1,
                 (SELECT gate_account.*, gate_log_online.action_time FROM gate_log_online LEFT JOIN gate_account
											ON gate_account.userid = gate_log_online.userid
										WHERE DATE(gate_account.createtime) = p_date_30
											AND gate_account.userid = gate_log_online.userid) AS t2
            WHERE t2.userid = t1.userid)
		ON DUPLICATE KEY UPDATE `new_user_retention_30` = VALUES(`new_user_retention_30`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_player_query_online
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_player_query_online`;

CREATE PROCEDURE `__oss_do_player_query_online`(IN `p_userid` varchar(50))
BEGIN
	-- 
	SELECT user_attribute.*, user_state.heartbeat_time AS heartbeattime, user_state.logout_time AS logouttime, user_state.login_time AS logintime
		FROM user_attribute INNER JOIN user_state
		ON user_state.`userid` = user_attribute.`userid` AND user_state.`userid` = p_userid
		LIMIT 1;

END;

-- ----------------------------
-- Procedure structure for __oss_do_player_query_charge
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_player_query_charge`;

CREATE PROCEDURE `__oss_do_player_query_charge`(IN `p_userid` varchar(50), IN `p_begintime` datetime, IN `p_endtime` datetime)
BEGIN
	-- 
	SELECT user_attribute.*, game_charge.charge_type, game_charge.charge_cash, game_charge.charge_state, game_charge.createtime AS charge_time, game_charge.goodsid
		FROM user_attribute INNER JOIN game_charge
		ON user_attribute.`userid` = game_charge.`userid` AND user_attribute.`userid` = p_userid
		ORDER BY charge_time DESC;

END;

-- ----------------------------
-- Table structure for i_game_mail
-- ----------------------------
DROP TABLE IF EXISTS `i_game_mail`;
CREATE TABLE `i_game_mail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '邮件id',
  `subid` int(11) NOT NULL COMMENT '子id，用于排序',
  `mailtype` int(11) NOT NULL COMMENT '邮件类型，0 = 未知类型，1 = 系统补偿，2 = 首充，3 = 月卡',
  `sender_type` int(11) NOT NULL COMMENT '寄件类型，0 = 系统，1 = 私人',
  `sender_userid` varchar(50) NOT NULL COMMENT '寄件人地址',
  `sender_role_nick` varchar(50) NOT NULL COMMENT '寄件人角色昵称',
  `mailto_type` int(11) NOT NULL COMMENT '收件类型，0 = 全体，1 = 单体',
  `mailto_userid` varchar(50) NOT NULL COMMENT '收件人地址',
  `mailto_level` int(11) NOT NULL DEFAULT '0' COMMENT '收件人等级限制， 0 = 不限制',
  `ignore_rule` int(11) NOT NULL DEFAULT '0' COMMENT '用户忽略规则， 0 = 不忽略， 1 = 忽略新注册用户',
  `subject` varchar(500) NOT NULL COMMENT '邮件主题',
  `content` varchar(500) NOT NULL COMMENT '邮件正文',
  `attachment` varchar(500) NOT NULL COMMENT '附件物品',
  `createtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '生成时间',
  `burntime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '销毁时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Procedure structure for __oss_create_game_mail
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_create_game_mail`;

CREATE PROCEDURE `__oss_create_game_mail`(IN `p_subid` int, IN `p_mailtype` int, IN `p_subject` varchar(500), IN `p_content` varchar(500), IN `p_attachment` varchar(500), IN `p_createtime` datetime, IN `p_burntime` datetime, IN `p_mailto_level` int, IN `p_ignore_rule` int)
BEGIN
	-- 
	INSERT INTO i_game_mail(`subid`, `mailtype`, `sender_type`, `sender_userid`, `sender_role_nick`,
													`mailto_type`, `mailto_userid`, `mailto_level`, `ignore_rule`,
													`subject`, `content`, `attachment`,
													`createtime`, `burntime`)
			VALUES(p_subid,p_mailtype,99,'oss','GM系统邮件后台', 0,'everybody',p_mailto_level,p_ignore_rule, p_subject,p_content,p_attachment, p_createtime,p_burntime);
END;

-- ----------------------------
-- Procedure structure for __oss_create_game_mail_private
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_create_game_mail_private`;

CREATE PROCEDURE `__oss_create_game_mail_private`(IN `p_subid` int, IN `p_mailtype` int, IN `p_userid` varchar(50), IN `p_subject` varchar(500), IN `p_content` varchar(500), IN `p_attachment` varchar(500))
BEGIN
	DECLARE p_burntime datetime DEFAULT 0;
	SET p_burntime = '2999-01-01';

	-- 
	INSERT INTO i_game_mail(`subid`, `mailtype`, `sender_type`, `sender_userid`, `sender_role_nick`,
													`mailto_type`, `mailto_userid`, `mailto_level`, `ignore_rule`,
													`subject`, `content`, `attachment`,
													`createtime`, `burntime`)
			VALUES(p_subid,p_mailtype,99,'oss(private)','GM邮件后台(私人)', 1,p_userid,0,1, p_subject,p_content,p_attachment, NOW(),p_burntime);
END;

-- ----------------------------
-- Table structure for game_announcement
-- ----------------------------
DROP TABLE IF EXISTS `game_announcement`;
CREATE TABLE `game_announcement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `circle_seconds` int(11) DEFAULT NULL,
  `read` tinyint(1) DEFAULT NULL,
  `data` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Procedure structure for __oss_create_game_announcement
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_create_game_announcement`;

CREATE PROCEDURE `__oss_create_game_announcement`(IN `p_deadlinetime` datetime, IN `p_playinterval` int, IN `p_data` varchar(1000))
BEGIN
	-- DECLARE p_now datetime DEFAULT 0;
	-- DECLARE p_deadline datetime DEFAULT 0;
	-- SET p_now = NOW();
	-- SET p_deadline = DATE_ADD(p_now,INTERVAL 10 MINUTE);

	-- 
	INSERT INTO game_announcement(`type`, `timestamp`, `circle_seconds`, `read`, `data`)
			VALUES(1, p_deadlinetime, p_playinterval, 1, p_data);
END;

-- ----------------------------
-- Table structure for _log_user_cost_diamond
-- ----------------------------
DROP TABLE IF EXISTS `_log_user_cost_diamond`;
CREATE TABLE `_log_user_cost_diamond` (
  `userid` varchar(50) NOT NULL,
  `way` int(11) NOT NULL,
  `param` bigint(20) NOT NULL,
  `cost_num` int(11) DEFAULT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`userid`,`way`,`param`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for _oss_news
-- ----------------------------
DROP TABLE IF EXISTS `_oss_news`;
CREATE TABLE `_oss_news` (
  `Id` char(36) NOT NULL,
  `CreateBy` char(36) DEFAULT NULL,
  `CreateTime` datetime DEFAULT NULL,
  `Content` varchar(4096) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for _oss_stats_charge
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_charge`;
CREATE TABLE `_oss_stats_charge` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `charge_num` int(11) NOT NULL COMMENT '今日充值次数',
  `charge_cash` float NOT NULL COMMENT '今日充值RMB金额（元）',
  `charge_user_num` int(11) NOT NULL COMMENT '今日充值人数',
  `total_charge_num` int(11) NOT NULL COMMENT '充值总次数',
  `total_charge_cash` float NOT NULL COMMENT '充值总额',
  `total_charge_user_num` int(11) NOT NULL COMMENT '充值总人数',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_diamond
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_diamond`;
CREATE TABLE `_oss_stats_diamond` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `production_speed_up` int(11) NOT NULL COMMENT '加速生产',
  `dungeon_revive` int(11) NOT NULL COMMENT '塔内复活',
  `ghost_ship_reset` int(11) NOT NULL COMMENT '重置幽灵船',
  `equip_reset_refine_times` int(11) NOT NULL COMMENT '重置装备洗练次数',
  `equip_refine` int(11) NOT NULL COMMENT '装备洗练',
  `shopping_bargain` int(11) NOT NULL COMMENT '商人议价',
  `shopping_buy` int(11) NOT NULL COMMENT '商店购买',
  `sailor_exchange_skill` int(11) NOT NULL COMMENT '换技能',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_diamond2
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_diamond2`;
CREATE TABLE `_oss_stats_diamond2` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `production_speed_up` int(11) NOT NULL COMMENT '加速生产',
  `dungeon_revive` int(11) NOT NULL COMMENT '塔内复活',
  `ghost_ship_reset` int(11) NOT NULL COMMENT '重置幽灵船',
  `equip_reset_refine_times` int(11) NOT NULL COMMENT '重置装备洗练次数',
  `equip_refine` int(11) NOT NULL COMMENT '装备洗练',
  `shopping_bargain` int(11) NOT NULL COMMENT '商人议价',
  `shopping_buy` int(11) NOT NULL COMMENT '商店购买',
  `sailor_exchange_skill` int(11) NOT NULL COMMENT '换技能',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_game
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_game`;
CREATE TABLE `_oss_stats_game` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `accumulate_role` int(11) NOT NULL COMMENT '累积用户数',
  `new_role` int(11) NOT NULL COMMENT '新角色数',
  `lv01_05` int(11) NOT NULL COMMENT '等级',
  `lv06_10` int(11) NOT NULL COMMENT '等级',
  `lv11_15` int(11) NOT NULL COMMENT '等级',
  `lv16_20` int(11) NOT NULL COMMENT '等级',
  `lv21_30` int(11) NOT NULL COMMENT '等级',
  `lv31_50` int(11) NOT NULL COMMENT '等级',
  `lv51_99` int(11) NOT NULL COMMENT '等级',
  `stage_1_1` int(11) NOT NULL COMMENT '关卡',
  `stage_1_2` int(11) NOT NULL COMMENT '关卡',
  `accumulate_charge` bigint(20) NOT NULL COMMENT '累积充值元',
  `new_charge` bigint(20) NOT NULL COMMENT '新充值元数',
  `new_charge_uncleared` bigint(20) NOT NULL COMMENT '新充值元未到帐数',
  `new_user_charge` bigint(20) NOT NULL COMMENT '新充值元数',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_game_quest
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_game_quest`;
CREATE TABLE `_oss_stats_game_quest` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `questid` int(11) NOT NULL COMMENT '进行中',
  `busy` int(11) NOT NULL COMMENT '进行中',
  `completed` int(11) NOT NULL COMMENT '完成',
  PRIMARY KEY (`day`,`questid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_game_role_level
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_game_role_level`;
CREATE TABLE `_oss_stats_game_role_level` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `role_level` bigint(20) NOT NULL COMMENT '进行中',
  `num` int(11) NOT NULL COMMENT '数量',
  PRIMARY KEY (`day`,`role_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_game_stage
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_game_stage`;
CREATE TABLE `_oss_stats_game_stage` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `stageid` bigint(20) NOT NULL COMMENT '进行中',
  `open` int(11) NOT NULL COMMENT '进行中',
  `pass` int(11) NOT NULL COMMENT '进行中',
  PRIMARY KEY (`day`,`stageid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_online
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_online`;
CREATE TABLE `_oss_stats_online` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `accumulate_user` int(11) NOT NULL COMMENT '累积用户数',
  `new_user` int(11) NOT NULL COMMENT '新用户数',
  `new_role` int(11) NOT NULL COMMENT '新角色数',
  `online_users` int(11) NOT NULL COMMENT '在线用户总数',
  `online_ips` int(11) NOT NULL COMMENT '在线用户ip总数',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_online_hour
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_online_hour`;
CREATE TABLE `_oss_stats_online_hour` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `h_00` int(11) NOT NULL COMMENT '时间段',
  `h_02` int(11) NOT NULL COMMENT '时间段',
  `h_06` int(11) NOT NULL COMMENT '时间段',
  `h_08` int(11) NOT NULL COMMENT '时间段',
  `h_09` int(11) NOT NULL COMMENT '时间段',
  `h_10` int(11) NOT NULL COMMENT '时间段',
  `h_13` int(11) NOT NULL COMMENT '时间段',
  `h_19` int(11) NOT NULL COMMENT '时间段',
  `h_21` int(11) NOT NULL COMMENT '时间段',
  `h_23` int(11) NOT NULL COMMENT '时间段',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Table structure for _oss_stats_online_hour2
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_online_hour2`;
CREATE TABLE `_oss_stats_online_hour2` (
  `day` date NOT NULL DEFAULT '0000-00-00' COMMENT '日期',
  `h_00` int(11) NOT NULL COMMENT '时间段',
  `h_02` int(11) NOT NULL COMMENT '时间段',
  `h_06` int(11) NOT NULL COMMENT '时间段',
  `h_08` int(11) NOT NULL COMMENT '时间段',
  `h_09` int(11) NOT NULL COMMENT '时间段',
  `h_10` int(11) NOT NULL COMMENT '时间段',
  `h_13` int(11) NOT NULL COMMENT '时间段',
  `h_19` int(11) NOT NULL COMMENT '时间段',
  `h_21` int(11) NOT NULL COMMENT '时间段',
  `h_23` int(11) NOT NULL COMMENT '时间段',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Procedure structure for __oss_do_stats_all
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_all`;

CREATE PROCEDURE `__oss_do_stats_all`()
BEGIN
	DECLARE p_begin datetime DEFAULT 0;
	DECLARE p_end datetime DEFAULT 0;

	DECLARE i INT DEFAULT 0;
	DECLARE day_num int DEFAULT 0;
	DECLARE the_day datetime DEFAULT 0;

	SET p_end = CURDATE();
	SET p_begin = DATE_SUB(p_end,INTERVAL 1 DAY);
	-- SET p_begin = '2018-11-17';

	SELECT (TO_DAYS(p_end) - TO_DAYS(p_begin)) INTO day_num;
	WHILE i<=day_num
	DO
		-- 
		SET the_day = DATE_ADD(p_begin,INTERVAL i DAY);

		--
		CALL __oss_do_stats_online(the_day);
		CALL __oss_do_stats_online_hour(the_day);
		CALL __oss_do_stats_charge(the_day);
		CALL __oss_do_stats_diamond(the_day);
		CALL __oss_do_stats_diamond2(the_day);
		CALL __oss_do_stats_retention(the_day);

		--
		SET i=i+1;
	END WHILE;
END;


-- ----------------------------
-- Procedure structure for __oss_do_stats_charge
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_charge`;

CREATE PROCEDURE `__oss_do_stats_charge`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `charge_num`)
		SELECT p_date AS `day`, COUNT(*) AS `charge_num` FROM game_charge WHERE TO_DAYS(createtime) = TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `charge_num` = VALUES(`charge_num`);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `charge_cash`)
		SELECT p_date AS `day`, SUM(charge_cash) AS `charge_cash` FROM game_charge WHERE TO_DAYS(createtime) = TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `charge_cash` = VALUES(`charge_cash`);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `charge_user_num`)
		SELECT p_date AS `day`, COUNT(DISTINCT(`userid`)) AS `charge_user_num` FROM game_charge WHERE TO_DAYS(createtime) = TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `charge_user_num` = VALUES(`charge_user_num`);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `total_charge_num`)
		SELECT p_date AS `day`, COUNT(*) AS `total_charge_num` FROM game_charge WHERE TO_DAYS(createtime) <= TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `total_charge_num` = VALUES(`total_charge_num`);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `total_charge_cash`)
		SELECT p_date AS `day`, SUM(charge_cash) AS `total_charge_cash` FROM game_charge WHERE TO_DAYS(createtime) <= TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `total_charge_cash` = VALUES(`total_charge_cash`);

	-- 
	INSERT INTO _oss_stats_charge(`day`, `total_charge_user_num`)
		SELECT p_date AS `day`, COUNT(DISTINCT(`userid`)) AS `total_charge_user_num` FROM game_charge WHERE TO_DAYS(createtime) <= TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `total_charge_user_num` = VALUES(`total_charge_user_num`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_diamond
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_diamond`;

CREATE PROCEDURE `__oss_do_stats_diamond`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 1
	INSERT INTO _oss_stats_diamond(`day`, `production_speed_up`)
		SELECT p_date AS `day`, SUM(cost_num) AS `production_speed_up` 
			FROM _log_user_cost_diamond
				WHERE `way` = 1 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `production_speed_up` = VALUES(`production_speed_up`);

	-- 2
	INSERT INTO _oss_stats_diamond(`day`, `dungeon_revive`)
		SELECT p_date AS `day`, SUM(cost_num) AS `dungeon_revive` 
			FROM _log_user_cost_diamond
				WHERE `way` = 2 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `dungeon_revive` = VALUES(`dungeon_revive`);
	
	-- 3
	INSERT INTO _oss_stats_diamond(`day`, `ghost_ship_reset`)
		SELECT p_date AS `day`, SUM(cost_num) AS `ghost_ship_reset` 
			FROM _log_user_cost_diamond
				WHERE `way` = 3 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `ghost_ship_reset` = VALUES(`ghost_ship_reset`);

	-- 4
	INSERT INTO _oss_stats_diamond(`day`, `equip_reset_refine_times`)
		SELECT p_date AS `day`, SUM(cost_num) AS `equip_reset_refine_times` 
			FROM _log_user_cost_diamond
				WHERE `way` = 4 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `equip_reset_refine_times` = VALUES(`equip_reset_refine_times`);

	-- 5
	INSERT INTO _oss_stats_diamond(`day`, `equip_refine`)
		SELECT p_date AS `day`, SUM(cost_num) AS `equip_refine` 
			FROM _log_user_cost_diamond
				WHERE `way` = 5 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `equip_refine` = VALUES(`equip_refine`);

	-- 6
	INSERT INTO _oss_stats_diamond(`day`, `shopping_bargain`)
		SELECT p_date AS `day`, SUM(cost_num) AS `shopping_bargain` 
			FROM _log_user_cost_diamond
				WHERE `way` = 6 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `shopping_bargain` = VALUES(`shopping_bargain`);

	-- 7
	INSERT INTO _oss_stats_diamond(`day`, `shopping_buy`)
		SELECT p_date AS `day`, SUM(cost_num) AS `shopping_buy` 
			FROM _log_user_cost_diamond
				WHERE `way` = 7 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `shopping_buy` = VALUES(`shopping_buy`);

	-- 8
	INSERT INTO _oss_stats_diamond(`day`, `sailor_exchange_skill`)
		SELECT p_date AS `day`, SUM(cost_num) AS `sailor_exchange_skill` 
			FROM _log_user_cost_diamond
				WHERE `way` = 8 AND TO_DAYS(`timestamp`) = TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `sailor_exchange_skill` = VALUES(`sailor_exchange_skill`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_diamond2
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_diamond2`;

CREATE PROCEDURE `__oss_do_stats_diamond2`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 1
	INSERT INTO _oss_stats_diamond2(`day`, `production_speed_up`)
		SELECT p_date AS `day`, SUM(cost_num) AS `production_speed_up` 
			FROM _log_user_cost_diamond
				WHERE `way` = 1 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `production_speed_up` = VALUES(`production_speed_up`);

	-- 2
	INSERT INTO _oss_stats_diamond2(`day`, `dungeon_revive`)
		SELECT p_date AS `day`, SUM(cost_num) AS `dungeon_revive` 
			FROM _log_user_cost_diamond
				WHERE `way` = 2 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `dungeon_revive` = VALUES(`dungeon_revive`);
	
	-- 3
	INSERT INTO _oss_stats_diamond2(`day`, `ghost_ship_reset`)
		SELECT p_date AS `day`, SUM(cost_num) AS `ghost_ship_reset` 
			FROM _log_user_cost_diamond
				WHERE `way` = 3 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `ghost_ship_reset` = VALUES(`ghost_ship_reset`);

	-- 4
	INSERT INTO _oss_stats_diamond2(`day`, `equip_reset_refine_times`)
		SELECT p_date AS `day`, SUM(cost_num) AS `equip_reset_refine_times` 
			FROM _log_user_cost_diamond
				WHERE `way` = 4 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `equip_reset_refine_times` = VALUES(`equip_reset_refine_times`);

	-- 5
	INSERT INTO _oss_stats_diamond2(`day`, `equip_refine`)
		SELECT p_date AS `day`, SUM(cost_num) AS `equip_refine` 
			FROM _log_user_cost_diamond
				WHERE `way` = 5 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `equip_refine` = VALUES(`equip_refine`);

	-- 6
	INSERT INTO _oss_stats_diamond2(`day`, `shopping_bargain`)
		SELECT p_date AS `day`, SUM(cost_num) AS `shopping_bargain` 
			FROM _log_user_cost_diamond
				WHERE `way` = 6 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `shopping_bargain` = VALUES(`shopping_bargain`);

	-- 7
	INSERT INTO _oss_stats_diamond2(`day`, `shopping_buy`)
		SELECT p_date AS `day`, SUM(cost_num) AS `shopping_buy` 
			FROM _log_user_cost_diamond
				WHERE `way` = 7 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `shopping_buy` = VALUES(`shopping_buy`);

	-- 8
	INSERT INTO _oss_stats_diamond2(`day`, `sailor_exchange_skill`)
		SELECT p_date AS `day`, SUM(cost_num) AS `sailor_exchange_skill` 
			FROM _log_user_cost_diamond
				WHERE `way` = 8 AND TO_DAYS(`timestamp`) <= TO_DAYS(p_day) 
		ON DUPLICATE KEY UPDATE `sailor_exchange_skill` = VALUES(`sailor_exchange_skill`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_game
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_game`;

CREATE PROCEDURE `__oss_do_stats_game`()
BEGIN
	DECLARE p_deadline datetime DEFAULT 0;
	SET p_deadline = DATE_SUB(CURDATE(),INTERVAL 1 DAY);

	-- 
	INSERT INTO _oss_stats_game(`day`, `accumulate_role`)
		SELECT p_deadline AS `day`, COUNT(*) AS `new_role` FROM user_role 
			WHERE TO_DAYS(createtime) <= TO_DAYS(p_deadline)
		ON DUPLICATE KEY UPDATE `accumulate_role` = VALUES(`accumulate_role`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `new_role`)
		SELECT p_deadline AS `day`, COUNT(*) AS `new_role` FROM user_role
			WHERE TO_DAYS(createtime) = TO_DAYS(p_deadline)
		ON DUPLICATE KEY UPDATE `new_role` = VALUES(`new_role`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `accumulate_charge`)
		SELECT p_deadline AS `day`, SUM(charge_cash) AS `accumulate_charge` FROM game_charge
			WHERE TO_DAYS(createtime) <= TO_DAYS(p_deadline)
		ON DUPLICATE KEY UPDATE `accumulate_role` = VALUES(`accumulate_role`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `new_charge`)
		SELECT p_deadline AS `day`, SUM(charge_cash) AS `new_charge` FROM game_charge
			WHERE TO_DAYS(createtime) = TO_DAYS(p_deadline)
		ON DUPLICATE KEY UPDATE `new_charge` = VALUES(`new_charge`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `new_charge_uncleared`)
		SELECT p_deadline AS `day`, SUM(charge_cash) AS `new_charge_uncleared` FROM game_charge
			WHERE TO_DAYS(createtime) = TO_DAYS(p_deadline)
				AND (charge_state = 1 OR charge_state = 3)
		ON DUPLICATE KEY UPDATE `new_charge` = VALUES(`new_charge`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `new_user_charge`)
		SELECT p_deadline AS `day`, SUM(charge_cash) AS `new_user_charge` FROM game_charge AS t1, user_role AS t2
			WHERE TO_DAYS(t1.createtime) = TO_DAYS(p_deadline)
				AND TO_DAYS(t2.createtime) = TO_DAYS(p_deadline)
		ON DUPLICATE KEY UPDATE `new_user_charge` = VALUES(`new_user_charge`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `lv01_05`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv01_05` FROM user_role
			WHERE `level` BETWEEN 1 AND 5
		ON DUPLICATE KEY UPDATE `lv01_05` = VALUES(`lv01_05`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `lv06_10`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv06_10` FROM user_role
			WHERE `level` BETWEEN 6 AND 10
		ON DUPLICATE KEY UPDATE `lv06_10` = VALUES(`lv06_10`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `lv11_15`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv11_15` FROM user_role
			WHERE `level` BETWEEN 11 AND 15
		ON DUPLICATE KEY UPDATE `lv11_15` = VALUES(`lv11_15`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `lv16_20`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv16_20` FROM user_role
			WHERE `level` BETWEEN 16 AND 20
		ON DUPLICATE KEY UPDATE `lv16_20` = VALUES(`lv16_20`);

	-- 
	INSERT INTO _oss_stats_game(`day`, `lv21_30`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv21_30` FROM user_role
			WHERE `level` BETWEEN 21 AND 30
		ON DUPLICATE KEY UPDATE `lv21_30` = VALUES(`lv21_30`);

	--
	INSERT INTO _oss_stats_game(`day`, `lv31_50`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv31_50` FROM user_role
			WHERE `level` BETWEEN 31 AND 50
		ON DUPLICATE KEY UPDATE `lv31_50` = VALUES(`lv31_50`);

	--
	INSERT INTO _oss_stats_game(`day`, `lv51_99`)
		SELECT p_deadline AS `day`, COUNT(*) AS `lv51_99` FROM user_role
			WHERE `level` BETWEEN 51 AND 100
		ON DUPLICATE KEY UPDATE `lv51_99` = VALUES(`lv51_99`);

	--
	INSERT INTO _oss_stats_game(`day`, `stage_1_1`)
		SELECT p_deadline AS `day`, COUNT(*) AS `stage_1_1` FROM user_stage
			WHERE `stage_state` = 2 AND `sceneid` = 4101010004
		ON DUPLICATE KEY UPDATE `stage_1_1` = VALUES(`stage_1_1`);

	--
	INSERT INTO _oss_stats_game(`day`, `stage_1_2`)
		SELECT p_deadline AS `day`, COUNT(*) AS `stage_1_2` FROM user_stage
			WHERE `stage_state` = 2 AND `sceneid` = 4101020005
		ON DUPLICATE KEY UPDATE `stage_1_2` = VALUES(`stage_1_2`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_game_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_game_quest`;

CREATE PROCEDURE `__oss_do_stats_game_quest`()
BEGIN
	DECLARE p_deadline date DEFAULT 0;
	SET p_deadline = DATE_SUB(CURDATE(),INTERVAL 1 DAY);

	-- 
	INSERT INTO _oss_stats_game_quest(`day`, `questid`, `busy`)
		SELECT p_deadline AS `day`, `slotid` AS `questid`, COUNT(*) AS `busy` FROM user_quest_slot
			WHERE `slot_state` = 2
			GROUP BY `questid`
		ON DUPLICATE KEY UPDATE `busy` = VALUES(`busy`);

	-- 
	INSERT INTO _oss_stats_game_quest(`day`, `questid`, `completed`)
		SELECT p_deadline AS `day`, `slotid` AS `questid`, COUNT(*) AS `completed` FROM user_quest_slot
			WHERE (`slot_state` = 3 OR `slot_state` = 4)
			GROUP BY `questid`
		ON DUPLICATE KEY UPDATE `busy` = VALUES(`busy`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_game_role_level
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_game_role_level`;

CREATE PROCEDURE `__oss_do_stats_game_role_level`()
BEGIN
	DECLARE p_deadline date DEFAULT 0;
	SET p_deadline = DATE_SUB(CURDATE(),INTERVAL 1 DAY);

	-- 
	INSERT INTO _oss_stats_game_role_level(`day`, `role_level`, `num`)
		SELECT p_deadline AS `day`, `level` AS `role_level`, COUNT(*) AS `num` FROM user_role
			GROUP BY `role_level`
		ON DUPLICATE KEY UPDATE `num` = VALUES(`num`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_game_stage
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_game_stage`;

CREATE PROCEDURE `__oss_do_stats_game_stage`()
BEGIN
	DECLARE p_deadline date DEFAULT 0;
	SET p_deadline = DATE_SUB(CURDATE(),INTERVAL 1 DAY);

	-- 
	INSERT INTO _oss_stats_game_stage(`day`, `stageid`, `open`)
		SELECT p_deadline AS `day`, `sceneid` AS `stageid`, COUNT(*) AS `busy` FROM user_stage
			WHERE `stage_state` = 1
			GROUP BY `stageid`
		ON DUPLICATE KEY UPDATE `open` = VALUES(`open`);

	-- 
	INSERT INTO _oss_stats_game_stage(`day`, `stageid`, `pass`)
		SELECT p_deadline AS `day`, `sceneid` AS `stageid`, COUNT(*) AS `completed` FROM user_stage
			WHERE `stage_state` = 2
			GROUP BY `stageid`
		ON DUPLICATE KEY UPDATE `pass` = VALUES(`pass`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_online
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_online`;

CREATE PROCEDURE `__oss_do_stats_online`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 
	INSERT INTO _oss_stats_online(`day`, `new_user`)
		SELECT p_date AS `day`, COUNT(*) AS `new_user` FROM gate_account WHERE TO_DAYS(createtime) = TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `new_user` = VALUES(`new_user`);

	-- 
	INSERT INTO _oss_stats_online(`day`, `accumulate_user`)
		SELECT p_date AS `day`, COUNT(*) AS `accumulate_user` FROM gate_account WHERE TO_DAYS(createtime) <= TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `accumulate_user` = VALUES(`accumulate_user`);

	-- 
	INSERT INTO _oss_stats_online(`day`, `new_role`)
		SELECT p_date AS `day`, COUNT(*) AS `new_role` FROM user_attribute WHERE TO_DAYS(createtime) = TO_DAYS(p_day)
		ON DUPLICATE KEY UPDATE `new_role` = VALUES(`new_role`);

	-- 
	INSERT INTO _oss_stats_online(`day`, `online_users`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `online_users` FROM gate_log_online 
			WHERE action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_users` = VALUES(`online_users`);

	-- 
	INSERT INTO _oss_stats_online(`day`, `online_ips`)
		SELECT p_date AS `day`, COUNT(DISTINCT(`ip`)) AS `online_ips` FROM gate_log_online
			WHERE action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 1 DAY)
		ON DUPLICATE KEY UPDATE `online_ips` = VALUES(`online_ips`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_online_hour
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_online_hour`;

CREATE PROCEDURE `__oss_do_stats_online_hour`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_00`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_00` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_SUB(p_date,INTERVAL 1 HOUR) AND p_date
		ON DUPLICATE KEY UPDATE `h_00` = VALUES(`h_00`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_02`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_02` FROM gate_log_online 
			WHERE action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 2 HOUR)
		ON DUPLICATE KEY UPDATE `h_02` = VALUES(`h_02`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_06`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_06` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 2 HOUR) AND DATE_ADD(p_date,INTERVAL 6 HOUR)
		ON DUPLICATE KEY UPDATE `h_06` = VALUES(`h_06`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_08`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_08` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 6 HOUR) AND DATE_ADD(p_date,INTERVAL 8 HOUR)
		ON DUPLICATE KEY UPDATE `h_08` = VALUES(`h_08`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_09`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_09` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 8 HOUR) AND DATE_ADD(p_date,INTERVAL 9 HOUR)
		ON DUPLICATE KEY UPDATE `h_09` = VALUES(`h_09`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_10`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_10` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 9 HOUR) AND DATE_ADD(p_date,INTERVAL 10 HOUR)
		ON DUPLICATE KEY UPDATE `h_10` = VALUES(`h_10`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_13`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_13` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 10 HOUR) AND DATE_ADD(p_date,INTERVAL 13 HOUR)
		ON DUPLICATE KEY UPDATE `h_13` = VALUES(`h_13`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_19`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_19` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 13 HOUR) AND DATE_ADD(p_date,INTERVAL 19 HOUR)
		ON DUPLICATE KEY UPDATE `h_19` = VALUES(`h_19`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_21`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_21` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 19 HOUR) AND DATE_ADD(p_date,INTERVAL 21 HOUR)
		ON DUPLICATE KEY UPDATE `h_21` = VALUES(`h_21`);

	-- 
	INSERT INTO _oss_stats_online_hour(`day`, `h_23`)
		SELECT p_date AS `day`, COUNT(DISTINCT(userid)) AS `h_23` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 21 HOUR) AND DATE_ADD(p_date,INTERVAL 23 HOUR)
		ON DUPLICATE KEY UPDATE `h_23` = VALUES(`h_23`);

END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_online_hour2
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_online_hour2`;

CREATE PROCEDURE `__oss_do_stats_online_hour2`(IN `p_day` datetime)
BEGIN
	DECLARE p_date datetime DEFAULT 0;
	SET p_date = DATE(p_day);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_00`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_00` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_SUB(p_date,INTERVAL 1 HOUR) AND p_date
		ON DUPLICATE KEY UPDATE `h_00` = VALUES(`h_00`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_02`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_02` FROM gate_log_online 
			WHERE action_time BETWEEN p_date AND DATE_ADD(p_date,INTERVAL 2 HOUR)
		ON DUPLICATE KEY UPDATE `h_02` = VALUES(`h_02`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_06`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_06` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 2 HOUR) AND DATE_ADD(p_date,INTERVAL 6 HOUR)
		ON DUPLICATE KEY UPDATE `h_06` = VALUES(`h_06`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_08`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_08` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 6 HOUR) AND DATE_ADD(p_date,INTERVAL 8 HOUR)
		ON DUPLICATE KEY UPDATE `h_08` = VALUES(`h_08`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_09`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_09` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 8 HOUR) AND DATE_ADD(p_date,INTERVAL 9 HOUR)
		ON DUPLICATE KEY UPDATE `h_09` = VALUES(`h_09`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_10`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_10` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 9 HOUR) AND DATE_ADD(p_date,INTERVAL 10 HOUR)
		ON DUPLICATE KEY UPDATE `h_10` = VALUES(`h_10`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_13`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_13` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 10 HOUR) AND DATE_ADD(p_date,INTERVAL 13 HOUR)
		ON DUPLICATE KEY UPDATE `h_13` = VALUES(`h_13`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_19`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_19` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 13 HOUR) AND DATE_ADD(p_date,INTERVAL 19 HOUR)
		ON DUPLICATE KEY UPDATE `h_19` = VALUES(`h_19`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_21`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_21` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 19 HOUR) AND DATE_ADD(p_date,INTERVAL 21 HOUR)
		ON DUPLICATE KEY UPDATE `h_21` = VALUES(`h_21`);

	-- 
	INSERT INTO _oss_stats_online_hour2(`day`, `h_23`)
		SELECT p_date AS `day`, MAX(concurrent_users) AS `h_23` FROM gate_log_online 
			WHERE action_time BETWEEN DATE_ADD(p_date,INTERVAL 21 HOUR) AND DATE_ADD(p_date,INTERVAL 23 HOUR)
		ON DUPLICATE KEY UPDATE `h_23` = VALUES(`h_23`);

END;

-- ----------------------------
-- Table structure for _oss_stats_online_snapshot
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_online_snapshot`;
CREATE TABLE `_oss_stats_online_snapshot` (
  `timepoint` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '日期',
  `userid` varchar(255) NOT NULL,
  `ticketid` int(11) NOT NULL,
  `nick` varchar(255) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `exp` int(11) DEFAULT NULL,
  `portrait` int(11) DEFAULT NULL,
  `signature` varchar(500) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL COMMENT '军衔，官阶',
  `optime` datetime DEFAULT NULL COMMENT '操作时间戳',
  `createtime` datetime DEFAULT NULL COMMENT '创建时间戳',
  `heartbeattime` datetime DEFAULT NULL COMMENT '心跳时间',
  `logouttime` datetime DEFAULT NULL COMMENT '登出时间',
  `logintime` datetime DEFAULT NULL COMMENT '登入时间',
    PRIMARY KEY (`timepoint`,`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for _oss_stats_online_snapshot_g
-- ----------------------------
DROP TABLE IF EXISTS `_oss_stats_online_snapshot_g`;
CREATE TABLE `_oss_stats_online_snapshot_g` (
  `timepoint` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '日期',
  `userid` varchar(50) NOT NULL COMMENT '累积用户数',
  `server_id` int(11) DEFAULT NULL,
  `ip` varchar(100) DEFAULT NULL COMMENT '用户ip',
  `action_time` datetime DEFAULT NULL COMMENT '操作时间戳',
  PRIMARY KEY (`timepoint`,`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Procedure structure for __oss_do_stats_online_snapshot
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_online_snapshot`;

CREATE PROCEDURE `__oss_do_stats_online_snapshot`(IN `p_query_time` datetime)
BEGIN
	--
	DELETE FROM _oss_stats_online_snapshot;

	-- 
	INSERT INTO _oss_stats_online_snapshot(`timepoint`, `userid`, `ticketid`, `nick`, `level`, `exp`, `portrait`, `signature`, `rank`, `optime`, `createtime`, `heartbeattime`, `logouttime`, `logintime`)
		SELECT p_query_time AS `timepoint`, t.`userid`, t.`ticketid`, t.`nick`, t.`level`, t.`exp`, t.`portrait`, t.`signature`, t.`rank`, t.`optime`, t.`createtime`, t.`heartbeattime`, t.`logouttime`, t.`logintime`
			FROM (
				SELECT user_attribute.*, user_state.heartbeat_time AS heartbeattime, user_state.logout_time AS logouttime, user_state.login_time AS logintime
					FROM user_attribute INNER JOIN user_state
					ON user_state.`userid` = user_attribute.`userid`
			) AS t
			WHERE NOT ISNULL(t.logintime) 
				AND (t.logintime BETWEEN DATE_SUB(p_query_time,INTERVAL 10 MINUTE) AND DATE_ADD(p_query_time,INTERVAL 10 MINUTE) 
							OR (t.heartbeattime BETWEEN DATE_SUB(p_query_time,INTERVAL 10 MINUTE) AND DATE_ADD(p_query_time,INTERVAL 10 MINUTE)));

	-- return snapshot
	SELECT * FROM _oss_stats_online_snapshot;
END;

-- ----------------------------
-- Procedure structure for __oss_do_stats_online_snapshot_g
-- ----------------------------
DROP PROCEDURE IF EXISTS `__oss_do_stats_online_snapshot_g`;

CREATE PROCEDURE `__oss_do_stats_online_snapshot_g`()
BEGIN
	DECLARE p_now datetime DEFAULT 0;
	SET p_now = NOW();
	-- SET p_now = '2017-01-01';

	--
	DELETE FROM _oss_stats_online_snapshot_g;

	-- 
	INSERT INTO _oss_stats_online_snapshot_g
		SELECT p_now AS `timepoint`, t.`userid`, t.`server_id`, t.`ip`, t.`action_time`
			FROM (
				SELECT gate_log_online.*
					FROM gate_log_online
					WHERE gate_log_online.`action_time` > DATE_SUB(p_now, INTERVAL 31 MINUTE)
					GROUP BY gate_log_online.`userid` ORDER BY gate_log_online.`action_time` ASC
			) AS t
			WHERE t.action_type = 3 or t.action_type = 1;

END;


-- ----------------------------
-- Event structure for _oss_do_stats
-- ----------------------------
DROP EVENT IF EXISTS `_oss_do_stats`;

CREATE EVENT `_oss_do_stats` ON SCHEDULE EVERY 1 DAY STARTS '2017-06-09 03:00:00' ON COMPLETION PRESERVE ENABLE DO CALL __oss_do_stats_all();