-- ============================================
-- 购物系统数据库脚本
-- ============================================
DROP DATABASE IF EXISTS shopping;
CREATE DATABASE shopping DEFAULT CHARACTER SET utf8;
USE shopping;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- 商品表
-- ----------------------------
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `picture` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- 商品数据
-- ----------------------------
INSERT INTO `items` VALUES ('1', '沃特篮球鞋', '佛山', '180', '500', '001.jpg');
INSERT INTO `items` VALUES ('2', '安踏运动鞋', '福州', '120', '800', '002.jpg');
INSERT INTO `items` VALUES ('3', '耐克运动鞋', '广州', '500', '1000', '003.jpg');
INSERT INTO `items` VALUES ('4', '阿迪达斯T血衫', '上海', '388', '600', '004.jpg');
INSERT INTO `items` VALUES ('5', '李宁文化衫', '广州', '180', '900', '005.jpg');
INSERT INTO `items` VALUES ('6', '小米3', '北京', '1999', '3000', '006.jpg');
INSERT INTO `items` VALUES ('7', '小米2S', '北京', '1299', '1000', '007.jpg');
INSERT INTO `items` VALUES ('8', 'thinkpad笔记本', '北京', '6999', '500', '008.jpg');
INSERT INTO `items` VALUES ('9', 'dell笔记本', '北京', '3999', '500', '009.jpg');
INSERT INTO `items` VALUES ('10', 'ipad5', '北京', '5999', '500', '010.jpg');

-- ----------------------------
-- 订单表
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `orderId` varchar(50) NOT NULL,
  `num` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `state` int(11) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- 订单项表
-- ----------------------------
DROP TABLE IF EXISTS `ordersitem`;
CREATE TABLE `ordersitem` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `num` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `orders_id` int(11) DEFAULT NULL,
  `good_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_id` (`orders_id`),
  KEY `good_id` (`good_id`),
  CONSTRAINT `ordersitem_ibfk_1` FOREIGN KEY (`orders_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `ordersitem_ibfk_2` FOREIGN KEY (`good_id`) REFERENCES `items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
