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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,14,'hmt hills','hyderabad','telangana','500072','India','secondary','2024-10-23 10:03:09'),(2,8,'hmt hills','hyderabad','telangana','500072','India','secondary','2024-10-23 23:01:21'),(3,3,'kphb','hyderabad','telangana','500072','India','secondary','2024-10-24 04:52:06'),(4,16,'Pragathi nagar','Hyderabad','Telangana','500043','India','default','2024-10-26 02:10:13'),(5,17,'line ','hyderabad','telangana','500043','India','default','2024-10-26 10:52:22');
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
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (5,15,4,'dove soap','',1,5584,5584,'2024-10-20 06:28:32'),(9,17,4,'dove soap','',1,5584,5584,'2024-10-20 06:45:59'),(18,27,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 07:41:33'),(19,28,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 07:41:50'),(20,29,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 07:48:42'),(21,30,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 07:51:28'),(22,31,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 07:58:36'),(34,43,4,'dove soap','dove_soap.jpeg',1,5584,5584,'2024-10-26 08:46:30'),(35,44,4,'dove soap','dove_soap.jpeg',1,5584,5584,'2024-10-26 08:46:45'),(36,45,5,'Compact Powder','powder.jpg',1,150,150,'2024-10-26 17:41:44'),(37,46,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-26 18:08:51'),(40,48,9,'soap','soap.jpeg',1,150.45,150.45,'2024-10-27 07:38:52'),(41,49,4,'dove soap','dove_soap.jpeg',1,5081.44,5081.44,'2024-10-27 07:43:02'),(42,50,9,'soap','soap.jpeg',1,150.45,150.45,'2024-10-27 07:48:33'),(43,51,10,'something','bg.jpeg',1,0,0,'2024-10-27 07:50:46'),(44,52,10,'something','bg.jpeg',1,0,0,'2024-10-27 07:57:53'),(45,53,10,'something','bg.jpeg',1,0,0,'2024-10-27 08:17:32'),(46,54,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 08:19:14'),(47,55,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 08:20:32'),(48,56,6,'shampoo','shampoo.jpg',1,763.3,763.3,'2024-10-27 08:21:19'),(49,57,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 08:21:49'),(50,58,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 08:22:32'),(51,59,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 08:22:48'),(52,60,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:01:10'),(53,61,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:02:15'),(54,62,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:04:03'),(55,63,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:25:06'),(56,64,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:32:56'),(57,65,10,'something','bg.jpeg',1,0,0,'2024-10-27 09:42:07'),(58,66,5,'Compact Powder','powder.jpg',1,135,135,'2024-10-27 09:46:55');
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
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'WY6W0CXW',5,19773,'2024-10-11 11:48:34','2024-10-06 06:18:34',NULL,50),(2,'GV7B2JAD',5,898,'2024-10-20 11:20:44','2024-10-15 05:50:44',NULL,50),(3,'IL7DTTP4',7,898,'2024-10-20 12:12:39','2024-10-15 06:42:39',NULL,50),(4,'JSAXI4NN',8,898,'2024-10-20 12:41:36','2024-10-15 07:11:36',NULL,50),(5,'94NMJIEI',8,1225,'2024-10-20 12:43:16','2024-10-15 07:13:16',NULL,50),(6,'F4MGOEOB',11,4573,'2024-10-21 11:21:56','2024-10-16 05:51:56',NULL,50),(7,'ONB2DPW6',11,1225,'2024-10-21 11:22:49','2024-10-16 05:52:49',NULL,50),(8,'IYKPDYWW',3,898,'2024-10-21 18:49:11','2024-10-16 13:19:11',NULL,50),(9,'5ARZ0TFH',3,898,'2024-10-22 12:12:21','2024-10-17 06:42:21',NULL,50),(10,'L77HCG8H',1,1796,'2024-10-22 12:56:15','2024-10-17 07:26:15',NULL,50),(12,'CK298Q08',3,898,'2024-10-24 13:15:14','2024-10-19 07:45:14',NULL,50),(13,'ZY5Z2FNL',3,2694,'2024-10-24 13:28:36','2024-10-19 07:58:36',NULL,50),(14,'JVM11R9K',3,177,'2024-10-24 14:40:18','2024-10-19 09:10:18',NULL,50),(15,'U4RWP32Z',3,6482,'2024-10-25 11:58:32','2024-10-20 06:28:33',NULL,50),(16,'5NISQ2V2',3,2123,'2024-10-25 12:05:43','2024-10-20 06:35:43',NULL,50),(17,'UJNS58O8',3,6809,'2024-10-25 12:16:00','2024-10-20 06:46:00',NULL,50),(19,'FNXNHPGD',3,1225,'2024-10-25 14:46:39','2024-10-20 09:16:39',NULL,50),(20,'P47CYF4W',3,1225,'2024-10-25 17:51:32','2024-10-20 12:21:32',NULL,50),(21,'CSX2AUKA',3,898,'2024-10-25 18:10:22','2024-10-20 12:40:22',NULL,50),(22,'D1VQNIN7',3,898,'2024-10-25 18:13:15','2024-10-20 12:43:15',NULL,50),(23,'VAD3VEJH',NULL,898,'2024-10-26 20:26:51','2024-10-21 14:56:51',NULL,50),(24,'R1HOIN2C',14,177,'2024-10-28 21:01:42','2024-10-23 15:31:42',1,50),(25,'9PEWLT68',8,177,'2024-10-29 10:01:01','2024-10-24 04:31:01',2,50),(26,'G0B9GC7Z',3,1225,'2024-10-29 15:51:23','2024-10-24 10:21:23',3,50),(27,'7SJ3Y6KW',16,150,'2024-10-31 13:11:33','2024-10-26 07:41:33',NULL,50),(28,'BW5Y8D1D',16,150,'2024-10-31 13:11:50','2024-10-26 07:41:50',NULL,50),(29,'DI0O3VUW',16,150,'2024-10-31 13:18:42','2024-10-26 07:48:42',NULL,50),(30,'U1FCYEYD',16,150,'2024-10-31 13:21:28','2024-10-26 07:51:28',NULL,50),(31,'8ST4J8TB',16,150,'2024-10-31 13:28:37','2024-10-26 07:58:37',NULL,50),(32,'Z9YIDS7T',16,898,'2024-10-31 13:32:30','2024-10-26 08:02:30',NULL,50),(33,'3CW6APCN',16,898,'2024-10-31 13:33:51','2024-10-26 08:03:51',NULL,50),(34,'DIEJ465A',3,1225,'2024-10-31 13:36:29','2024-10-26 08:06:29',NULL,50),(35,'EC13BC98',16,177,'2024-10-31 13:38:44','2024-10-26 08:08:44',NULL,50),(36,'IQBM9JEW',16,898,'2024-10-31 13:45:42','2024-10-26 08:15:42',NULL,50),(37,'4NOT3WAQ',3,1225,'2024-10-31 13:47:54','2024-10-26 08:17:54',NULL,50),(38,'LO7HBQB7',3,177,'2024-10-31 13:48:05','2024-10-26 08:18:05',NULL,50),(39,'W78LBZQO',3,898,'2024-10-31 13:49:47','2024-10-26 08:19:47',NULL,50),(40,'QZFOOXTN',3,898,'2024-10-31 13:54:05','2024-10-26 08:24:05',NULL,50),(41,'FIWRSKDA',3,177,'2024-10-31 13:55:40','2024-10-26 08:25:40',3,50),(42,'TCOFQAGL',3,898,'2024-10-31 14:14:28','2024-10-26 08:44:28',NULL,50),(43,'9VOYCZNH',3,5584,'2024-10-31 14:16:30','2024-10-26 08:46:30',NULL,50),(44,'LPFCGELT',3,5584,'2024-10-31 14:16:45','2024-10-26 08:46:45',3,50),(45,'818IL983',17,150,'2024-10-31 23:11:45','2024-10-26 17:41:45',5,50),(46,'U4IUVPYU',17,135,'2024-10-31 23:38:52','2024-10-26 18:08:52',5,50),(47,'58A49UJL',17,1890.3,'2024-11-01 10:24:30','2024-10-27 04:54:30',5,50),(48,'7J40ZJ9Z',13,5189.05,'2024-11-01 13:08:52','2024-10-27 07:38:52',NULL,50),(49,'1H7M9ZD4',13,10120,'2024-11-01 13:13:03','2024-10-27 07:43:03',NULL,50),(50,'O40J1YNL',13,5189.05,'2024-11-01 13:18:34','2024-10-27 07:48:34',NULL,50),(51,'8DU90ZRB',13,5038.6,'2024-11-01 13:20:46','2024-10-27 07:50:46',NULL,50),(52,'KTBS9K6V',13,5038.71,'2024-11-01 13:27:54','2024-10-27 07:57:54',NULL,50),(53,'RNAW14SB',13,0,'2024-11-01 13:47:33','2024-10-27 08:17:33',NULL,NULL),(54,'4PQ4VGRZ',17,5173.55,'2024-11-01 13:49:15','2024-10-27 08:19:15',NULL,5038.55),(55,'J7VVBFIF',17,5173.58,'2024-11-01 13:50:32','2024-10-27 08:20:32',NULL,5038.58),(56,'BYTZFR39',17,5801.88,'2024-11-01 13:51:20','2024-10-27 08:21:20',NULL,5038.58),(57,'5APAW2GB',17,5173.58,'2024-11-01 13:51:49','2024-10-27 08:21:49',NULL,5038.58),(58,'SEBS5WLE',17,5173.55,'2024-11-01 13:52:33','2024-10-27 08:22:33',NULL,5038.55),(59,'2Y8BXXR2',17,135,'2024-11-01 13:52:49','2024-10-27 08:22:49',NULL,5038.55),(60,'2Q81DU8R',13,0,'2024-11-01 14:31:10','2024-10-27 09:01:10',NULL,5038.71),(61,'Y7458768',13,0,'2024-11-01 14:32:15','2024-10-27 09:02:15',NULL,5038.71),(62,'3Y49QDX5',13,0,'2024-11-01 14:34:04','2024-10-27 09:04:04',NULL,5038.71),(63,'HYJE31E4',13,0,'2024-11-01 14:55:07','2024-10-27 09:25:07',NULL,5038.71),(64,'SX9LCYC7',13,0,'2024-11-01 15:02:56','2024-10-27 09:32:56',NULL,75),(65,'UJMJA1TY',3,75,'2024-11-01 15:12:07','2024-10-27 09:42:07',3,75),(66,'8J7SS0XV',3,210,'2024-11-01 15:16:56','2024-10-27 09:46:56',3,75);
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
INSERT INTO `product` VALUES (4,'dove soap','Shop for Dove Shea Butter Beauty Cream Moisturizing Bar Soap with Vanilla Scent online at Ubuy. Get the best deals and offers on Ubuy, a India.',5584,9,'bodycare','',19,1594,'dove_soap.jpeg'),(5,'Compact Powder','Makeup Powder',150,10,'Makeup','Lakme',10,8756,'powder.jpg'),(6,'shampoo','tresme shapoo for smooth hair',898,15,'Haircare','Matrix',16,5678,'shampoo.jpg'),(8,'cream','a cream applied to face',1225,8,'Makeup','Lakme',20,1234,'face-cream.jpeg'),(9,'soap','Be 100% sure to protect your skin from 100 illness-causing germs and bacteria. Dettol\'s Intense Cool Protection bathing soap bar keeps your skin.',177,15,'Bodycare','Santoor',18,9101,'soap.jpeg'),(10,'something','Something is so special because it is special',0,0,'Tools','Vega',1,12555,'bg.jpeg');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','scrypt:32768:8:1$xh7SLm4bTn2sPY8N$a8da9327ef35ab42dd24abb888db1978ae2b72c1ea146ac9de81b692b6150c327189232664c31898d4764c7d5c2c437168f72a7eda8a27d8658e41930fcf5fc4','admin@gmail.com','9392584801','Male','admin',NULL,NULL),(3,'shyam','scrypt:32768:8:1$XfGIMkBl3PZprw5z$2b6770b0e7d6ac7ebbab036eb76eef2c0a1b2539036080fbdcb076a11293b23061847e0c6a12cfdf257c5d6981d237926aa1b58fe6b8dd990e96ac6e61f7ab7c','shyam@gmail.com','9392584801','Male','user',17.5048,78.3984),(5,'nithin','scrypt:32768:8:1$ImaYkCDhsF7FGRl1$03622beae070846c2644aae57361bfe6e0743a1fe14c124b61cf9d5dcef85e289529e51545c64dfee9a26c6c0afc9f5bf0c0d95485fa6efb0d730958a08b8638','shyamkoushikp@gmail.com','9392584801','Male','user',NULL,NULL),(7,'maniratan','scrypt:32768:8:1$TXwMXz8tkhZ9QA8i$7b522ca49cc0022b68157d0100309e479a2c939d35e39a4ad6ae04b62b90014651faa50b4f713581b75a31b78c05f140bcae13f7e665698a4b88547b2c998cdf','mani56@gmail.com','8247209015','Male','user',NULL,NULL),(8,'aasd','scrypt:32768:8:1$B2gevardFv6MefzS$82f712424a2f3e614b9d1fbba085e7abf420359a290f128e2d06c11ebc55253308005d883dfe9d677a7a5a79d75aef63342b479f1feffeb3451ee21e81af8d6e','n1613922@student.narayanagroup.com','9392584801','Male','guest',NULL,NULL),(9,'Devudu','scrypt:32768:8:1$qec6ChsFkbDxmsnJ$e0a5dc88e25c6e9dfe9975c49f2fc6cbdd9fcfa3b143117000b92b1d89fcc3cf4b2d034122c11db34dc74a5ec249f7dd28fd31b73c6cf42ddb8bb991b49d94b3','21r21a05h0@mlrinstitutions.ac.in','8247209015','Male','user',NULL,NULL),(11,'devudu1','scrypt:32768:8:1$r8slXt8RSZohaPfO$682788f4e5f598e568d885b5ffe76ebca739471439b107e38f4682591d658d209e1ee6e72dc5c0bf66dd38f26ef0bacf82a0ff934d38919fe74e6eff07c491f6','devudu@gmail.com','2345627839','Male','guest',NULL,NULL),(12,'admin1','scrypt:32768:8:1$0YAC9N4sr2vvN5fw$ffae7d31db04fa8a454221737a2ce101b5e93896a8466b53d1edee024a956859a21c304eee721822ad6f9b83756395fbc7999c13cfb60a3dc622377e985fa823','admin1@gmail.com','1234567890','Male','admin',NULL,NULL),(13,'hello','scrypt:32768:8:1$RXSKGu0gnZcmwSZr$641b17fd6f7a05638b062acf00d6ff375e8565b1756d8e8ef3d08b9e7be46f947053632a2158211860b2c725d64bdad575e800c02c68aa695fb8293170cce9b0','hello@gmail.com','1234567891','Male','user',17.5046,78.3987),(14,'ram','scrypt:32768:8:1$7Mm9gxbH4mDv4elo$359bb6d8ce4d42f53e4f008919d1a15514f9db36a4021f22334eff497b57348d7a857199c47cb9b7d791680a2469449fd4ca2d8ebdb6196b97b7d87598bb8674','ram@gmail.com','1234567890','Male','guest',NULL,NULL),(15,'Nikki','scrypt:32768:8:1$RebnzNZJAWzGyg2v$414437eadd6e62b979fd9ca40d7af6a7f821b6835bd9d24ccd17ccfc0e81245f6b4ce56bc0729517dbbd1e507fb79afa550140284abde953af9b19e4c6e820ab','lakshminikitha0267@gmail.com','8008177355','Female','user',NULL,NULL),(16,'Nikitha','scrypt:32768:8:1$05AaArhG9kGgcQEo$c8c7cc264ec9f105ee0d014d76b435aa5d7ad929369734ca255fec3fe603cc78707cc80fe03035f9e1ae868e291bb3bc98146eb50999ffeb027e38e649f6d05a','21r21a05g9@mlrinstitutions.ac.in','08008177355','Female','user',NULL,NULL),(17,'arun','scrypt:32768:8:1$KJ7PdsMpl0Qeup9j$9de8bc9c8729d512bb8a95e1bf408863be02db7419806586f0b1ee2e53abfb6aa860dac5e818f313bd3aff1403aea4dc6ded14954fabfdfe9346983700c29819','arun@gmail.com','1234567890','Male','user',17.5045,78.3984);
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

-- Dump completed on 2024-10-27 17:59:30
