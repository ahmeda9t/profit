-- MySQL dump 10.13  Distrib 8.4.0, for macos13.2 (arm64)
--
-- Host: localhost    Database: profit_store
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'dc2fede4-cf05-11f0-9b36-b21f812b521c:1-86';

--
-- Table structure for table `Brands`
--

DROP TABLE IF EXISTS `Brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Brands` (
  `brand_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`brand_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Brands`
--

LOCK TABLES `Brands` WRITE;
/*!40000 ALTER TABLE `Brands` DISABLE KEYS */;
INSERT INTO `Brands` VALUES (1,'Nike'),(2,'Adidas'),(3,'ProFit'),(4,'Nike'),(5,'Adidas'),(6,'ProFit'),(7,'Nike'),(8,'Adidas'),(9,'ProFit'),(10,'Nike'),(11,'Adidas'),(12,'ProFit');
/*!40000 ALTER TABLE `Brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Categories`
--

DROP TABLE IF EXISTS `Categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Categories`
--

LOCK TABLES `Categories` WRITE;
/*!40000 ALTER TABLE `Categories` DISABLE KEYS */;
INSERT INTO `Categories` VALUES (1,'Footwear'),(2,'Clothing'),(3,'Gym Equipment'),(4,'Footwear'),(5,'Gym Equipment'),(6,'Clothing'),(7,'Footwear'),(8,'Gym Equipment'),(9,'Clothing'),(10,'Footwear'),(11,'Gym Equipment'),(12,'Clothing'),(13,'NFL Gear'),(14,'Baseball Gear');
/*!40000 ALTER TABLE `Categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Customers`
--

DROP TABLE IF EXISTS `Customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `loyalty_points` int DEFAULT '0',
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customers`
--

LOCK TABLES `Customers` WRITE;
/*!40000 ALTER TABLE `Customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `Customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OrderLines`
--

DROP TABLE IF EXISTS `OrderLines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OrderLines` (
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `line_total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `fk_ol_product` (`product_id`),
  CONSTRAINT `fk_ol_order` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`),
  CONSTRAINT `fk_ol_product` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OrderLines`
--

LOCK TABLES `OrderLines` WRITE;
/*!40000 ALTER TABLE `OrderLines` DISABLE KEYS */;
INSERT INTO `OrderLines` VALUES (1,1,1,59.99),(1,4,1,20.00),(2,44,1,59.99),(3,44,1,59.99),(4,42,1,29.99),(5,42,1,29.99),(6,42,1,29.99);
/*!40000 ALTER TABLE `OrderLines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int DEFAULT NULL,
  `employee_id` int NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivery_name` varchar(100) DEFAULT NULL,
  `delivery_phone` varchar(20) DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Processing','Shipped','Delivered') NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`order_id`),
  KEY `fk_orders_customer` (`customer_id`),
  KEY `fk_orders_employee` (`employee_id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`),
  CONSTRAINT `fk_orders_employee` FOREIGN KEY (`employee_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orders`
--

LOCK TABLES `Orders` WRITE;
/*!40000 ALTER TABLE `Orders` DISABLE KEYS */;
INSERT INTO `Orders` VALUES (1,NULL,5,79.99,0.00,'2025-12-03 02:31:33','ahmad','089798','hsgahig','Pending'),(2,NULL,5,59.99,0.00,'2025-12-03 03:20:44','karim','085367536','beirut','Pending'),(3,NULL,5,59.99,0.00,'2025-12-03 03:21:21','hussein','788678677','zahle','Pending'),(4,NULL,5,29.99,0.00,'2025-12-03 03:23:43','jad','09654432','beirut','Pending'),(5,NULL,5,29.99,0.00,'2025-12-03 03:24:12','Amir','0965432','jounieh','Pending'),(6,NULL,5,29.99,0.00,'2025-12-03 03:42:37','angela','+971 098765432','kuwait','Pending');
/*!40000 ALTER TABLE `Orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Payments`
--

DROP TABLE IF EXISTS `Payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `payment_method` enum('Cash','Card','Cash on Delivery','Credit Card','PayPal') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  KEY `fk_pay_order` (`order_id`),
  CONSTRAINT `fk_pay_order` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Payments`
--

LOCK TABLES `Payments` WRITE;
/*!40000 ALTER TABLE `Payments` DISABLE KEYS */;
INSERT INTO `Payments` VALUES (1,1,'Cash',79.99,'2025-12-03 02:31:33'),(2,2,'PayPal',59.99,'2025-12-03 03:20:44'),(3,3,'Cash on Delivery',59.99,'2025-12-03 03:21:21'),(4,4,'Cash on Delivery',29.99,'2025-12-03 03:23:43'),(5,5,'PayPal',29.99,'2025-12-03 03:24:12'),(6,6,'Cash on Delivery',29.99,'2025-12-03 03:42:37');
/*!40000 ALTER TABLE `Payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Products`
--

DROP TABLE IF EXISTS `Products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `brand_id` int NOT NULL,
  `supplier_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity_on_hand` int NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `badge` enum('New','Best Seller','Sale') DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `category_id` (`category_id`),
  KEY `brand_id` (`brand_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `Categories` (`category_id`),
  CONSTRAINT `products_ibfk_2` FOREIGN KEY (`brand_id`) REFERENCES `Brands` (`brand_id`),
  CONSTRAINT `products_ibfk_3` FOREIGN KEY (`supplier_id`) REFERENCES `Suppliers` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Products`
--

LOCK TABLES `Products` WRITE;
/*!40000 ALTER TABLE `Products` DISABLE KEYS */;
INSERT INTO `Products` VALUES (1,1,1,1,'Running Shoes',59.99,39,NULL,NULL),(2,3,3,1,'Yoga Mat',20.00,100,NULL,NULL),(4,2,3,1,'Yoga Mat',20.00,99,NULL,NULL),(9,3,6,1,'Dumbells',49.99,50,NULL,NULL),(10,1,1,1,'ProFit Run Elite Shoes',89.99,60,'run-elite.jpg',NULL),(11,1,1,1,'ProFit AirFlow Trainers',109.99,45,'airflow-trainers.jpg',NULL),(12,1,1,2,'ProFit Street Sprint Sneakers',79.99,80,'street-sprint.jpg',NULL),(13,1,2,2,'Adira Tempo Runner',69.99,70,NULL,NULL),(14,1,4,3,'UA Charge Sprint',99.99,50,NULL,NULL),(15,3,1,1,'ProFit DriMotion Tee (White)',29.99,120,'drimotion-tee-white.jpg',NULL),(16,3,1,1,'ProFit DriMotion Tee (Black)',29.99,100,'drimotion-tee-black.jpg',NULL),(17,3,2,2,'Adira Performance Shorts',34.99,90,NULL,NULL),(18,3,3,3,'ProFit Court Hoodie',59.99,40,NULL,NULL),(19,3,4,2,'UA Flex Joggers',54.99,55,NULL,NULL),(20,2,3,1,'ProFit Studio Yoga Mat Pro',39.99,150,'studio-yoga-mat.jpg',NULL),(21,2,3,1,'ProFit Foam Roller 45cm',24.99,80,NULL,NULL),(22,2,2,2,'Adira Steel Kettlebell 12kg',49.99,40,NULL,NULL),(23,2,4,3,'UA Training Bench Band Set',44.99,60,NULL,NULL),(24,2,1,2,'ProFit Speed Jump Rope',19.99,200,NULL,NULL),(25,4,1,1,'ProFit Everyday Cap',24.99,70,NULL,NULL),(26,4,1,1,'ProFit Performance Socks (3-pack)',17.99,200,NULL,NULL),(27,4,2,2,'Adira Gym Towel',14.99,90,NULL,NULL),(28,4,3,3,'ProFit Hydrate Bottle 1L',16.99,120,'hydrate-bottle.jpg',NULL),(29,4,4,3,'UA Training Gloves Pro',22.99,80,'training-gloves-pro.jpg',NULL),(30,5,1,1,'NFL ProFit Training Jersey',49.99,80,'nfl-training-jersey.jpg',NULL),(31,5,2,2,'NFL Adira Game Helmet Replica',129.99,25,'nfl-helmet.jpg',NULL),(32,5,3,3,'NFL ProFit Compression Shirt',39.99,100,'nfl-compression-shirt.jpg',NULL),(33,5,4,2,'UA NFL Sideline Hoodie',79.99,40,'nfl-hoodie.jpg',NULL),(34,5,1,1,'NFL ProFit Team Cap',29.99,90,'nfl-cap.jpg',NULL),(35,5,3,3,'NFL ProFit Receiver Gloves',34.99,70,'nfl-gloves.jpg',NULL),(36,5,2,2,'NFL Adira Shoulder Pads (Replica)',99.99,20,'nfl-shoulder-pads.jpg',NULL),(37,5,4,3,'UA NFL Performance Socks',17.99,150,'nfl-socks.jpg',NULL),(38,6,1,1,'ProFit Baseball Bat Pro Maple',119.99,35,'baseball-bat.jpg',NULL),(39,6,2,2,'Adira Baseball Bat Aluminum',89.99,50,'baseball-bat-aluminum.jpg',NULL),(40,6,3,3,'ProFit Leather Baseball Glove',99.99,45,'baseball-glove.jpg',NULL),(41,6,4,2,'UA Performance Baseball Cleats',109.99,30,'baseball-cleats.jpg',NULL),(42,6,1,1,'ProFit Official Game Baseball (Dozen)',29.99,57,'baseball-set.jpg',NULL),(43,6,3,3,'ProFit Catcher Chest Protector',139.99,15,'catcher-gear.jpg',NULL),(44,6,2,2,'Adira Baseball Helmet',59.99,38,'baseball-helmet.jpg',NULL),(45,6,4,3,'UA Baseball Training Shorts',34.99,75,'baseball-shorts.jpg',NULL);
/*!40000 ALTER TABLE `Products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Suppliers`
--

DROP TABLE IF EXISTS `Suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Suppliers`
--

LOCK TABLES `Suppliers` WRITE;
/*!40000 ALTER TABLE `Suppliers` DISABLE KEYS */;
INSERT INTO `Suppliers` VALUES (1,'Main Supplier','supplier@example.com'),(2,'Main Supplier','supplier@example.com'),(3,'Main Supplier','supplier@example.com'),(4,'Main Supplier','supplier@example.com');
/*!40000 ALTER TABLE `Suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('Admin','Customer') NOT NULL DEFAULT 'Customer',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,'admin','admin123','Admin'),(4,'zuzu','zuz&masri','Customer'),(5,'ahmad','zuzu','Customer');
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-03  3:45:16
