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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
INSERT INTO `cart_item` VALUES (35,'shampoo',2,898,1,898,'shampoo.jpg',13,NULL);
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,12,2,'shampoo','',1,898,898,'2024-10-19 07:45:13'),(2,13,2,'shampoo','',3,898,2694,'2024-10-19 07:58:36'),(3,14,3,'soap','',1,177,177,'2024-10-19 09:10:18'),(4,15,2,'shampoo','',1,898,898,'2024-10-20 06:28:32'),(5,15,4,'dove soap','',1,5584,5584,'2024-10-20 06:28:32'),(6,16,2,'shampoo','',1,898,898,'2024-10-20 06:35:43'),(7,16,1,'cream','',1,1225,1225,'2024-10-20 06:35:43'),(8,17,1,'cream','',1,1225,1225,'2024-10-20 06:45:59'),(9,17,4,'dove soap','',1,5584,5584,'2024-10-20 06:45:59'),(10,19,1,'cream','face-cream.jpeg',1,1225,1225,'2024-10-20 09:16:38'),(11,20,1,'cream','face-cream.jpeg',1,1225,1225,'2024-10-20 12:21:32'),(12,21,2,'shampoo','shampoo.jpg',1,898,898,'2024-10-20 12:40:21'),(13,22,2,'shampoo','shampoo.jpg',1,898,898,'2024-10-20 12:43:14'),(14,23,2,'shampoo','shampoo.jpg',1,898,898,'2024-10-21 14:56:51');
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `fk_address_id` (`address_id`),
  KEY `fk_user_id` (`user_id`),
  CONSTRAINT `fk_address_id` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'WY6W0CXW',5,19773,'2024-10-11 11:48:34','2024-10-06 06:18:34',NULL),(2,'GV7B2JAD',5,898,'2024-10-20 11:20:44','2024-10-15 05:50:44',NULL),(3,'IL7DTTP4',7,898,'2024-10-20 12:12:39','2024-10-15 06:42:39',NULL),(4,'JSAXI4NN',8,898,'2024-10-20 12:41:36','2024-10-15 07:11:36',NULL),(5,'94NMJIEI',8,1225,'2024-10-20 12:43:16','2024-10-15 07:13:16',NULL),(6,'F4MGOEOB',11,4573,'2024-10-21 11:21:56','2024-10-16 05:51:56',NULL),(7,'ONB2DPW6',11,1225,'2024-10-21 11:22:49','2024-10-16 05:52:49',NULL),(8,'IYKPDYWW',3,898,'2024-10-21 18:49:11','2024-10-16 13:19:11',NULL),(9,'5ARZ0TFH',3,898,'2024-10-22 12:12:21','2024-10-17 06:42:21',NULL),(10,'L77HCG8H',1,1796,'2024-10-22 12:56:15','2024-10-17 07:26:15',NULL),(12,'CK298Q08',3,898,'2024-10-24 13:15:14','2024-10-19 07:45:14',NULL),(13,'ZY5Z2FNL',3,2694,'2024-10-24 13:28:36','2024-10-19 07:58:36',NULL),(14,'JVM11R9K',3,177,'2024-10-24 14:40:18','2024-10-19 09:10:18',NULL),(15,'U4RWP32Z',3,6482,'2024-10-25 11:58:32','2024-10-20 06:28:33',NULL),(16,'5NISQ2V2',3,2123,'2024-10-25 12:05:43','2024-10-20 06:35:43',NULL),(17,'UJNS58O8',3,6809,'2024-10-25 12:16:00','2024-10-20 06:46:00',NULL),(19,'FNXNHPGD',3,1225,'2024-10-25 14:46:39','2024-10-20 09:16:39',NULL),(20,'P47CYF4W',3,1225,'2024-10-25 17:51:32','2024-10-20 12:21:32',NULL),(21,'CSX2AUKA',3,898,'2024-10-25 18:10:22','2024-10-20 12:40:22',NULL),(22,'D1VQNIN7',3,898,'2024-10-25 18:13:15','2024-10-20 12:43:15',NULL),(23,'VAD3VEJH',NULL,898,'2024-10-26 20:26:51','2024-10-21 14:56:51',NULL);
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
  `category` varchar(50) NOT NULL,
  `stock` int NOT NULL,
  `image` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'cream','a cream applied to face',1225,'makeup\n',10,'face-cream.jpeg'),(2,'shampoo','TRESemmé Keratin Smooth Shampoo helps your hair restore its keratin leaving them visibly straight and smoother. Infused with light-weight Argan Oil, this professional shampoo nourishes each strand of your hair making them silky smooth and easier to manage. This unique combination of Keratin and Argan Oil conditions and strengthens your hair and provides them hydration and elasticity. With its dual-action, TRESemmé Keratin Smooth Shampoo helps you get up to 100% smoother hair with more shine.',898,'Haircare',14,'shampoo.jpg'),(3,'soap','Be 100% sure to protect your skin from 100 illness-causing germs and bacteria. Dettol\'s Intense Cool Protection bathing soap bar keeps your skin.',177,'bodycare',16,'soap.jpeg'),(4,'dove soap','Shop for Dove Shea Butter Beauty Cream Moisturizing Bar Soap with Vanilla Scent online at Ubuy. Get the best deals and offers on Ubuy, a India.',5584,'bodycare',16,'dove_soap.jpeg');
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
  `user_type` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username_2` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','scrypt:32768:8:1$xh7SLm4bTn2sPY8N$a8da9327ef35ab42dd24abb888db1978ae2b72c1ea146ac9de81b692b6150c327189232664c31898d4764c7d5c2c437168f72a7eda8a27d8658e41930fcf5fc4','admin@gmail.com','9392584801','admin'),(3,'shyam','scrypt:32768:8:1$XfGIMkBl3PZprw5z$2b6770b0e7d6ac7ebbab036eb76eef2c0a1b2539036080fbdcb076a11293b23061847e0c6a12cfdf257c5d6981d237926aa1b58fe6b8dd990e96ac6e61f7ab7c','shyam@gmail.com','9392584801','user'),(5,'nithin','scrypt:32768:8:1$ImaYkCDhsF7FGRl1$03622beae070846c2644aae57361bfe6e0743a1fe14c124b61cf9d5dcef85e289529e51545c64dfee9a26c6c0afc9f5bf0c0d95485fa6efb0d730958a08b8638','shyamkoushikp@gmail.com','9392584801','user'),(7,'mani','scrypt:32768:8:1$TXwMXz8tkhZ9QA8i$7b522ca49cc0022b68157d0100309e479a2c939d35e39a4ad6ae04b62b90014651faa50b4f713581b75a31b78c05f140bcae13f7e665698a4b88547b2c998cdf','mani@gmail.com','mani','user'),(8,'aasd','scrypt:32768:8:1$B2gevardFv6MefzS$82f712424a2f3e614b9d1fbba085e7abf420359a290f128e2d06c11ebc55253308005d883dfe9d677a7a5a79d75aef63342b479f1feffeb3451ee21e81af8d6e','n1613922@student.narayanagroup.com','9392584801','guest'),(9,'Devudu','scrypt:32768:8:1$qec6ChsFkbDxmsnJ$e0a5dc88e25c6e9dfe9975c49f2fc6cbdd9fcfa3b143117000b92b1d89fcc3cf4b2d034122c11db34dc74a5ec249f7dd28fd31b73c6cf42ddb8bb991b49d94b3','21r21a05h0@mlrinstitutions.ac.in','8247209015','user'),(11,'devudu1','scrypt:32768:8:1$r8slXt8RSZohaPfO$682788f4e5f598e568d885b5ffe76ebca739471439b107e38f4682591d658d209e1ee6e72dc5c0bf66dd38f26ef0bacf82a0ff934d38919fe74e6eff07c491f6','devudu@gmail.com','2345627839','guest'),(12,'admin1','scrypt:32768:8:1$0YAC9N4sr2vvN5fw$ffae7d31db04fa8a454221737a2ce101b5e93896a8466b53d1edee024a956859a21c304eee721822ad6f9b83756395fbc7999c13cfb60a3dc622377e985fa823','admin1@gmail.com','1234567890','admin'),(13,'hello','scrypt:32768:8:1$RXSKGu0gnZcmwSZr$641b17fd6f7a05638b062acf00d6ff375e8565b1756d8e8ef3d08b9e7be46f947053632a2158211860b2c725d64bdad575e800c02c68aa695fb8293170cce9b0','hello@gmail.com','1234567891','user');
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

-- Dump completed on 2024-10-23 10:40:55
