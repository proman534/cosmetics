-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: cosmetics_db
-- ------------------------------------------------------
-- Server version	8.0.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `address_line` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(100) NOT NULL,
  `address_type` enum('default','secondary') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_user_address_id` (`user_id`),
  CONSTRAINT `fk_user_address_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,14,'hmt hills','hyderabad','telangana','500072','India','secondary','2024-10-23 10:03:09'),(2,8,'hmt hills','hyderabad','telangana','500072','India','secondary','2024-10-23 23:01:21'),(3,3,'kphb','hyderabad','telangana','500072','India','secondary','2024-10-24 04:52:06'),(4,16,'Pragathi nagar','Hyderabad','Telangana','500043','India','default','2024-10-26 02:10:13'),(5,17,'line ','hyderabad','telangana','500043','India','default','2024-10-26 10:52:22'),(6,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:41:39'),(7,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:42:06'),(8,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:44:07'),(9,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:47:33'),(10,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:48:55'),(11,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:55:38'),(12,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 07:55:51'),(13,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:10:11'),(14,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:17:00'),(15,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:18:19'),(16,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:20:46'),(17,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:21:53'),(18,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:22:09'),(19,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:28:08'),(20,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:34:41'),(21,3,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 08:36:44'),(22,13,'Miyapur Cross Roads','hyderabad','telangana','500049','India','secondary','2024-10-27 10:10:10');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_item`
--

DROP TABLE IF EXISTS `cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `product_id` int unsigned NOT NULL,
  `price` float NOT NULL,
  `quantity` int DEFAULT '1',
  `total` float NOT NULL,
  `image` varchar(200) DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `session_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_product` (`product_id`),
  KEY `fk_user` (`user_id`),
  CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_details`
--

DROP TABLE IF EXISTS `company_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_details`
--

LOCK TABLES `company_details` WRITE;
/*!40000 ALTER TABLE `company_details` DISABLE KEYS */;
INSERT INTO `company_details` VALUES (1,'Clarion','Makeup','clarion.png'),(2,'Fogg','Fragrances','fogg.jpg'),(3,'Lakme','Makeup','lakme.png'),(4,'Lilium','Skincare','lilium.jpg'),(5,'Loreal','Haircare','loreal.png'),(6,'Lotus','Skincare','lotus.png'),(7,'Matrix','Haircare','matrix.jpg'),(8,'MAYBELLINE','Makeup','maybelline.jpg'),(9,'Mr.Barber','Tools','barber.png'),(10,'Nandini','Skincare','nandini.png'),(11,'Raaga','Haircare','raaga.png'),(12,'Santoor','Bodycare','dettol.png'),(13,'Schwarzkopf','Haircare','schwarzkopf.png'),(14,'Vega','Tools','vega.jpg'),(15,'Wella','Haircare','wella.png');
/*!40000 ALTER TABLE `company_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact`
--

LOCK TABLES `contact` WRITE;
/*!40000 ALTER TABLE `contact` DISABLE KEYS */;
INSERT INTO `contact` VALUES (1,'mani','shyamkoushikp@gmail.com','thanks','2024-09-17 15:26:34');
/*!40000 ALTER TABLE `contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int unsigned NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `product_image` varchar(100) NOT NULL,
  `quantity` int NOT NULL,
  `price` float NOT NULL,
  `total` float NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `order_item_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_item_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (68,76,6,'shampoo','shampoo.jpg',1,763.3,763.3,'2024-10-27 16:11:17'),(69,77,5,'Compact Powder','powder.jpg',2,135,270,'2024-10-27 16:17:46'),(70,78,9,'soap','soap.jpeg',1,150.45,150.45,'2024-10-27 16:19:29'),(71,79,9,'soap','soap.jpeg',5,150.45,752.25,'2024-10-28 04:41:37'),(72,79,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-28 04:41:37');
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_number` varchar(8) NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `total_amount` float NOT NULL,
  `delivery_date` datetime NOT NULL,
  `placed_at` datetime NOT NULL,
  `address_id` int DEFAULT NULL,
  `delivery_charge` float DEFAULT '50',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `fk_address_id` (`address_id`),
  KEY `fk_user_id` (`user_id`),
  CONSTRAINT `fk_address_id` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (76,'XPWYWE6S',17,913.3,'2024-11-01 21:41:17','2024-10-27 16:11:17',5,75),(77,'VGIJBOPH',17,75,'2024-11-01 21:47:46','2024-10-27 16:17:46',5,75),(78,'F0TZUF7O',17,225.45,'2024-11-01 21:49:30','2024-10-27 16:19:30',5,75),(79,'EL6OE7BI',3,962.25,'2024-11-02 10:11:37','2024-10-28 04:41:37',3,75);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `price` float NOT NULL,
  `discount` float DEFAULT '0',
  `category` varchar(50) NOT NULL,
  `company` varchar(100) NOT NULL,
  `stock` int NOT NULL,
  `hsn_sac` int NOT NULL,
  `image` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (4,'dove soap','Shop for Dove Shea Butter Beauty Cream Moisturizing Bar Soap with Vanilla Scent online at Ubuy. Get the best deals and offers on Ubuy, a India.',5584,9,'bodycare','',19,1594,'dove_soap.jpeg'),(5,'Compact Powder','Makeup Powder',150,10,'Makeup','Lakme',0,8756,'powder.jpg'),(6,'shampoo','tresme shapoo for smooth hair',898,15,'Haircare','Matrix',11,5678,'shampoo.jpg'),(8,'cream','a cream applied to face',1225,8,'Makeup','Lakme',20,1234,'face-cream.jpeg'),(9,'soap','Be 100% sure to protect your skin from 100 illness-causing germs and bacteria. Dettol\'s Intense Cool Protection bathing soap bar keeps your skin.',177,15,'Bodycare','Santoor',13,9101,'soap.jpeg'),(10,'something','Something is so special because it is special',0,0,'Tools','Vega',0,12555,'bg.jpeg');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(150) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `user_type` varchar(150) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username_2` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','scrypt:32768:8:1$xh7SLm4bTn2sPY8N$a8da9327ef35ab42dd24abb888db1978ae2b72c1ea146ac9de81b692b6150c327189232664c31898d4764c7d5c2c437168f72a7eda8a27d8658e41930fcf5fc4','admin@gmail.com','9392584801','Male','admin',NULL,NULL),(3,'shyam','scrypt:32768:8:1$XfGIMkBl3PZprw5z$2b6770b0e7d6ac7ebbab036eb76eef2c0a1b2539036080fbdcb076a11293b23061847e0c6a12cfdf257c5d6981d237926aa1b58fe6b8dd990e96ac6e61f7ab7c','shyam@gmail.com','9392584801','Male','user',17.494,78.4008),(5,'nithin','scrypt:32768:8:1$ImaYkCDhsF7FGRl1$03622beae070846c2644aae57361bfe6e0743a1fe14c124b61cf9d5dcef85e289529e51545c64dfee9a26c6c0afc9f5bf0c0d95485fa6efb0d730958a08b8638','shyamkoushikp@gmail.com','9392584801','Male','user',NULL,NULL),(7,'maniratan','scrypt:32768:8:1$TXwMXz8tkhZ9QA8i$7b522ca49cc0022b68157d0100309e479a2c939d35e39a4ad6ae04b62b90014651faa50b4f713581b75a31b78c05f140bcae13f7e665698a4b88547b2c998cdf','mani56@gmail.com','8247209015','Male','user',NULL,NULL),(8,'aasd','scrypt:32768:8:1$B2gevardFv6MefzS$82f712424a2f3e614b9d1fbba085e7abf420359a290f128e2d06c11ebc55253308005d883dfe9d677a7a5a79d75aef63342b479f1feffeb3451ee21e81af8d6e','n1613922@student.narayanagroup.com','9392584801','Male','guest',NULL,NULL),(9,'Devudu','scrypt:32768:8:1$qec6ChsFkbDxmsnJ$e0a5dc88e25c6e9dfe9975c49f2fc6cbdd9fcfa3b143117000b92b1d89fcc3cf4b2d034122c11db34dc74a5ec249f7dd28fd31b73c6cf42ddb8bb991b49d94b3','21r21a05h0@mlrinstitutions.ac.in','8247209015','Male','user',NULL,NULL),(11,'devudu1','scrypt:32768:8:1$r8slXt8RSZohaPfO$682788f4e5f598e568d885b5ffe76ebca739471439b107e38f4682591d658d209e1ee6e72dc5c0bf66dd38f26ef0bacf82a0ff934d38919fe74e6eff07c491f6','devudu@gmail.com','2345627839','Male','guest',NULL,NULL),(12,'admin1','scrypt:32768:8:1$0YAC9N4sr2vvN5fw$ffae7d31db04fa8a454221737a2ce101b5e93896a8466b53d1edee024a956859a21c304eee721822ad6f9b83756395fbc7999c13cfb60a3dc622377e985fa823','admin1@gmail.com','1234567890','Male','admin',NULL,NULL),(13,'hello','scrypt:32768:8:1$RXSKGu0gnZcmwSZr$641b17fd6f7a05638b062acf00d6ff375e8565b1756d8e8ef3d08b9e7be46f947053632a2158211860b2c725d64bdad575e800c02c68aa695fb8293170cce9b0','hello@gmail.com','1234567891','Male','user',17.5046,78.3987),(14,'ram','scrypt:32768:8:1$7Mm9gxbH4mDv4elo$359bb6d8ce4d42f53e4f008919d1a15514f9db36a4021f22334eff497b57348d7a857199c47cb9b7d791680a2469449fd4ca2d8ebdb6196b97b7d87598bb8674','ram@gmail.com','1234567890','Male','guest',NULL,NULL),(15,'Nikki','scrypt:32768:8:1$RebnzNZJAWzGyg2v$414437eadd6e62b979fd9ca40d7af6a7f821b6835bd9d24ccd17ccfc0e81245f6b4ce56bc0729517dbbd1e507fb79afa550140284abde953af9b19e4c6e820ab','lakshminikitha0267@gmail.com','8008177355','Female','user',NULL,NULL),(16,'Nikitha','scrypt:32768:8:1$05AaArhG9kGgcQEo$c8c7cc264ec9f105ee0d014d76b435aa5d7ad929369734ca255fec3fe603cc78707cc80fe03035f9e1ae868e291bb3bc98146eb50999ffeb027e38e649f6d05a','21r21a05g9@mlrinstitutions.ac.in','08008177355','Female','user',NULL,NULL),(17,'arun','scrypt:32768:8:1$KJ7PdsMpl0Qeup9j$9de8bc9c8729d512bb8a95e1bf408863be02db7419806586f0b1ee2e53abfb6aa860dac5e818f313bd3aff1403aea4dc6ded14954fabfdfe9346983700c29819','arun@gmail.com','1234567890','Male','user',17.5045,78.3984),(18,'newtest','scrypt:32768:8:1$AJawT89n5z8Bwx2T$47bc3a4cd9b911d57083eff5567ab047796129eec002999fc22d4d6d7e584074c72029788cb8f1804b727837c84c16eb8f5e928f54d6f1c913455f84b16240f5','test@gmail.com','9987456321',NULL,'guest',NULL,NULL);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-28 12:05:13
