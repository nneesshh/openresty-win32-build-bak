/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : my_umb_web

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2018-12-03 09:40:52
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for departments
-- ----------------------------
DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments` (
  `Id` char(36) NOT NULL,
  `Code` text,
  `ContactNumber` text,
  `CreateBy` text,
  `CreateTime` datetime DEFAULT NULL,
  `IsDeleted` int(11) NOT NULL,
  `Manager` text,
  `Name` text,
  `ParentId` text,
  `Remarks` text,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of departments
-- ----------------------------
INSERT INTO `departments` VALUES ('5120cd33-33ff-4cc7-b0d8-36d52e5ace86', null, null, null, null, '0', null, '程序部', '00000000-0000-0000-0000-000000000000', null);

-- ----------------------------
-- Table structure for gamedburls
-- ----------------------------
DROP TABLE IF EXISTS `gamedburls`;
CREATE TABLE `gamedburls` (
  `Id` char(36) NOT NULL,
  `Name` text,
  `Type` int(11) NOT NULL,
  `Url` text,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of gamedburls
-- ----------------------------
INSERT INTO `gamedburls` VALUES ('fb145d88-39e7-4370-9c8f-7712f814c830', '苹果测试服A', '0', 'Server=127.0.0.1;Database=sandbox;Uid=root;Pwd=123123;CharSet=utf8;SslMode=None');

-- ----------------------------
-- Table structure for memberpreferredsettings
-- ----------------------------
DROP TABLE IF EXISTS `memberpreferredsettings`;
CREATE TABLE `memberpreferredsettings` (
  `MemberId` varchar(128) NOT NULL,
  `GameDbUrlId` text,
  `MenuId` text,
  PRIMARY KEY (`MemberId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of memberpreferredsettings
-- ----------------------------
INSERT INTO `memberpreferredsettings` VALUES ('test0001@b.com', 'fb145d88-39e7-4370-9c8f-7712f814c830', '00000000-0000-0000-0000-000000000000');

-- ----------------------------
-- Table structure for memberroles
-- ----------------------------
DROP TABLE IF EXISTS `memberroles`;
CREATE TABLE `memberroles` (
  `MemberId` varchar(128) NOT NULL,
  `RoleId` char(36) NOT NULL,
  PRIMARY KEY (`MemberId`,`RoleId`),
  KEY `IX_MemberRoles_RoleId` (`RoleId`),
  CONSTRAINT `FK_MemberRoles_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `roles` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of memberroles
-- ----------------------------
INSERT INTO `memberroles` VALUES ('test0001@b.com', '24ef2930-d755-4efb-b5dc-cde92eb905af');

-- ----------------------------
-- Table structure for menus
-- ----------------------------
DROP TABLE IF EXISTS `menus`;
CREATE TABLE `menus` (
  `Id` char(36) NOT NULL,
  `Code` text,
  `Icon` text,
  `Name` text,
  `ParentId` text,
  `Remarks` text,
  `SeqNo` int(11) NOT NULL,
  `Type` int(11) NOT NULL,
  `Url` text,
  `Hide` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of menus
-- ----------------------------
INSERT INTO `menus` VALUES ('10d66160-84d1-468b-93f7-81e6b99c8982', 'User', 'fa fa-link', '用户管理', '00000000-0000-0000-0000-000000000000', '', '3', '0', '/AdminUser', '1');
INSERT INTO `menus` VALUES ('10d66160-84d1-468b-93f7-81e6b99c8983', 'GamePlayer', 'fa fa-link', '游戏玩家数据查询', '00000000-0000-0000-0000-000000000000', '', '7', '0', '/PlayerManage', '0');
INSERT INTO `menus` VALUES ('7389c75c-cc61-40b7-909c-737d599347b7', 'Role', 'fa fa-link', '角色管理', '00000000-0000-0000-0000-000000000000', '', '2', '0', '/AdminRole', '1');
INSERT INTO `menus` VALUES ('7ea404ab-1de1-49be-b846-effbe2c85a1a', 'GameQuest', 'fa fa-link', '任务统计', '00000000-0000-0000-0000-000000000000', '', '13', '1', '/StatsUserQuest', '1');
INSERT INTO `menus` VALUES ('843e0bba-66f7-4190-8a98-6df4dafe15ab', 'Department', 'fa fa-link', '组织机构管理', '00000000-0000-0000-0000-000000000000', '', '1', '0', '/AdminDepartment', '1');
INSERT INTO `menus` VALUES ('9531cbcc-252a-44df-9444-9ee092f1aa9f', 'Charge', 'fa fa-link', '充值统计', '00000000-0000-0000-0000-000000000000', '', '12', '1', '/StatsUserCharge', '0');
INSERT INTO `menus` VALUES ('9e568cab-1c3e-4a8d-92f9-2a4926008d47', 'Online', 'fa fa-link', '在线统计', '00000000-0000-0000-0000-000000000000', '', '14', '1', '/StatsUserOnline', '0');
INSERT INTO `menus` VALUES ('cf6072f1-d246-4a57-a461-2a98f5ba270b', 'Diamond', 'fa fa-link', '钻石消费', '00000000-0000-0000-0000-000000000000', null, '11', '1', '/StatsUserDiamond', '0');
INSERT INTO `menus` VALUES ('d7f8090b-a07d-48df-9142-8bcc613c6d93', 'News', 'fa fa-link', '更新公告管理', '00000000-0000-0000-0000-000000000000', '', '4', '0', '/AdminNews', '0');
INSERT INTO `menus` VALUES ('d7f8090b-a07d-48df-9142-8bcc613c6d94', 'GameAnnouncement', 'fa fa-link', 'GM公告管理', '00000000-0000-0000-0000-000000000000', '', '5', '0', '/AdminGameAnnouncement', '0');
INSERT INTO `menus` VALUES ('d7f8090b-a07d-48df-9142-8bcc613c6d96', 'Mail', 'fa fa-link', 'GM邮件管理', '00000000-0000-0000-0000-000000000000', '', '6', '0', '/AdminMail', '0');
INSERT INTO `menus` VALUES ('e04d00ed-007f-4466-8eb8-668e17057888', 'OnlineHour', 'fa fa-link', '小时在线', '00000000-0000-0000-0000-000000000000', '', '15', '1', '/StatsUserOnlineHour', '0');
INSERT INTO `menus` VALUES ('f04d00ed-007f-4466-8eb8-668e17057888', 'OnlineSnapshot', 'fa fa-link', '当前在线', '00000000-0000-0000-0000-000000000000', '', '16', '1', '/StatsUserOnlineSnapshot', '0');

-- ----------------------------
-- Table structure for rolemenus
-- ----------------------------
DROP TABLE IF EXISTS `rolemenus`;
CREATE TABLE `rolemenus` (
  `RoleId` char(36) NOT NULL,
  `MenuId` char(36) NOT NULL,
  PRIMARY KEY (`RoleId`,`MenuId`),
  KEY `IX_RoleMenus_MenuId` (`MenuId`),
  CONSTRAINT `FK_RoleMenus_Menus_MenuId` FOREIGN KEY (`MenuId`) REFERENCES `menus` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_RoleMenus_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `roles` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of rolemenus
-- ----------------------------

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `Id` char(36) NOT NULL,
  `Code` text,
  `CreateBy` text,
  `CreateTime` datetime DEFAULT NULL,
  `Name` text,
  `Remarks` text,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES ('24ef2930-d755-4efb-b5dc-cde92eb905af', 'any', '00000000-0000-0000-0000-000000000000', '2018-05-23 08:59:27', 'DefaultRole', '缺省角色');

-- ----------------------------
-- Table structure for userroles
-- ----------------------------
DROP TABLE IF EXISTS `userroles`;
CREATE TABLE `userroles` (
  `UserId` char(36) NOT NULL,
  `RoleId` char(36) NOT NULL,
  PRIMARY KEY (`UserId`,`RoleId`),
  KEY `IX_UserRoles_RoleId` (`RoleId`),
  CONSTRAINT `FK_UserRoles_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `roles` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_UserRoles_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `users` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of userroles
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `Id` char(36) NOT NULL,
  `CreateBy` text,
  `CreateTime` datetime DEFAULT NULL,
  `DepartmentId` char(36) DEFAULT NULL,
  `EMail` text,
  `IsDeleted` int(11) NOT NULL,
  `LastLoginTime` datetime NOT NULL,
  `LoginTimes` int(11) NOT NULL,
  `MobileNumber` text,
  `Name` text,
  `Password` text,
  `Remarks` text,
  `UserName` text,
  PRIMARY KEY (`Id`),
  KEY `IX_Users_DepartmentId` (`DepartmentId`),
  CONSTRAINT `FK_Users_Departments_DepartmentId` FOREIGN KEY (`DepartmentId`) REFERENCES `departments` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('fc8639eb-7796-4f2f-a911-b789815ef360', null, null, '5120cd33-33ff-4cc7-b0d8-36d52e5ace86', null, '0', '0001-01-01 00:00:00', '0', null, '超级管理员', '123123', null, 'admin');

-- ----------------------------
-- Table structure for __efmigrationshistory
-- ----------------------------
DROP TABLE IF EXISTS `__efmigrationshistory`;
CREATE TABLE `__efmigrationshistory` (
  `MigrationId` varchar(150) NOT NULL,
  `ProductVersion` varchar(32) NOT NULL,
  PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of __efmigrationshistory
-- ----------------------------
INSERT INTO `__efmigrationshistory` VALUES ('20180523085730_Admin', '2.0.3-rtm-10026');
