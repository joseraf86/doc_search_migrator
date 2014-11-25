-- MySQL dump 10.13  Distrib 5.5.24, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: migracion_busconest
-- ------------------------------------------------------
-- Server version	5.5.24-0ubuntu0.12.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `area`
--

DROP TABLE IF EXISTS `area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `escuela_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_area_on_escuela_id` (`escuela_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `area`
--

LOCK TABLES `area` WRITE;
/*!40000 ALTER TABLE `area` DISABLE KEYS */;
/*!40000 ALTER TABLE `area` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `area_documento`
--

DROP TABLE IF EXISTS `area_documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_documento` (
  `area_id` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `area_documento`
--

LOCK TABLES `area_documento` WRITE;
/*!40000 ALTER TABLE `area_documento` DISABLE KEYS */;
/*!40000 ALTER TABLE `area_documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autor`
--

DROP TABLE IF EXISTS `autor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `persona_id` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_autor_on_persona_id` (`persona_id`),
  KEY `index_autor_on_documento_id` (`documento_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autor`
--

LOCK TABLES `autor` WRITE;
/*!40000 ALTER TABLE `autor` DISABLE KEYS */;
/*!40000 ALTER TABLE `autor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cindex`
--

DROP TABLE IF EXISTS `cindex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cindex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ocurrencia` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `termino_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cindex_on_documento_id` (`documento_id`),
  KEY `index_cindex_on_termino_id` (`termino_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cindex`
--

LOCK TABLES `cindex` WRITE;
/*!40000 ALTER TABLE `cindex` DISABLE KEYS */;
/*!40000 ALTER TABLE `cindex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clindex`
--

DROP TABLE IF EXISTS `clindex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clindex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ocurrencia` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `termino_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_clindex_on_documento_id` (`documento_id`),
  KEY `index_clindex_on_termino_id` (`termino_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clindex`
--

LOCK TABLES `clindex` WRITE;
/*!40000 ALTER TABLE `clindex` DISABLE KEYS */;
/*!40000 ALTER TABLE `clindex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido`
--

DROP TABLE IF EXISTS `contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contenido` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `texto` longtext COLLATE utf8_unicode_ci,
  `documento_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contenido_on_documento_id` (`documento_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido`
--

LOCK TABLES `contenido` WRITE;
/*!40000 ALTER TABLE `contenido` DISABLE KEYS */;
/*!40000 ALTER TABLE `contenido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documento`
--

DROP TABLE IF EXISTS `documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` longtext COLLATE utf8_unicode_ci,
  `resumen` mediumtext COLLATE utf8_unicode_ci,
  `fecha_publicacion` date DEFAULT NULL,
  `palabras_clave` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `escuela_id` int(11) DEFAULT NULL,
  `tipo_documento_id` int(11) DEFAULT NULL,
  `estado_documento_id` int(11) DEFAULT NULL,
  `idioma_id` int(11) DEFAULT NULL,
  `visibilidad_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `publicacion_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publicacion_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publicacion_file_size` int(11) DEFAULT NULL,
  `publicacion_updated_at` datetime DEFAULT NULL,
  `calificacion` int(11) DEFAULT NULL,
  `descargas` int(11) DEFAULT NULL,
  `paginas` int(11) DEFAULT NULL,
  `estado` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_documento_on_escuela_id` (`escuela_id`),
  KEY `index_documento_on_tipo_documento_id` (`tipo_documento_id`),
  KEY `index_documento_on_estado_documento_id` (`estado_documento_id`),
  KEY `index_documento_on_idioma_id` (`idioma_id`),
  KEY `index_documento_on_visibilidad_id` (`visibilidad_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documento`
--

LOCK TABLES `documento` WRITE;
/*!40000 ALTER TABLE `documento` DISABLE KEYS */;
/*!40000 ALTER TABLE `documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documento_reconocimiento`
--

DROP TABLE IF EXISTS `documento_reconocimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documento_reconocimiento` (
  `documento_id` int(11) DEFAULT NULL,
  `reconocimiento_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documento_reconocimiento`
--

LOCK TABLES `documento_reconocimiento` WRITE;
/*!40000 ALTER TABLE `documento_reconocimiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `documento_reconocimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `escuela`
--

DROP TABLE IF EXISTS `escuela`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `escuela` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `escuela`
--

LOCK TABLES `escuela` WRITE;
/*!40000 ALTER TABLE `escuela` DISABLE KEYS */;
INSERT INTO `escuela` VALUES (1,'BIOLOGIA','2013-03-02 15:59:00','2013-03-02 15:59:00'),(2,'COMPUTACION','2013-03-02 15:59:17','2013-03-02 15:59:17'),(3,'FISICA','2013-03-02 15:59:23','2013-03-02 15:59:23'),(4,'GEOQUIMICA','2013-03-02 15:59:30','2013-03-02 15:59:30'),(5,'MATEMATICA','2013-03-02 15:59:38','2013-03-02 15:59:38'),(6,'QUIMICA','2013-03-02 15:59:46','2013-03-02 15:59:46');
/*!40000 ALTER TABLE `escuela` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado_documento`
--

DROP TABLE IF EXISTS `estado_documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estado_documento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado_documento`
--

LOCK TABLES `estado_documento` WRITE;
/*!40000 ALTER TABLE `estado_documento` DISABLE KEYS */;
INSERT INTO `estado_documento` VALUES (1,'NUEVO','2013-06-18 19:34:28','2013-06-18 19:34:28'),(2,'INDEXADO','2013-06-18 19:34:38','2013-06-18 19:34:38');
/*!40000 ALTER TABLE `estado_documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estudiante`
--

DROP TABLE IF EXISTS `estudiante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estudiante` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `promedio_general` decimal(6,4) DEFAULT NULL,
  `promedio_ponderado` decimal(6,4) DEFAULT NULL,
  `eficiencia` decimal(6,4) DEFAULT NULL,
  `escuela_id` int(11) DEFAULT NULL,
  `grado_id` int(11) DEFAULT NULL,
  `persona_id` int(11) DEFAULT NULL,
  `mencion_id` int(11) DEFAULT NULL,
  `premio_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_estudiante_on_escuela_id` (`escuela_id`),
  KEY `index_estudiante_on_grado_id` (`grado_id`),
  KEY `index_estudiante_on_persona_id` (`persona_id`),
  KEY `index_estudiante_on_mencion_id` (`mencion_id`),
  KEY `index_estudiante_on_premio_id` (`premio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estudiante`
--

LOCK TABLES `estudiante` WRITE;
/*!40000 ALTER TABLE `estudiante` DISABLE KEYS */;
/*!40000 ALTER TABLE `estudiante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grado`
--

DROP TABLE IF EXISTS `grado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grado` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grado`
--

LOCK TABLES `grado` WRITE;
/*!40000 ALTER TABLE `grado` DISABLE KEYS */;
INSERT INTO `grado` VALUES (1,'PREGRADO','2013-06-18 19:47:13','2013-06-18 19:50:54'),(2,'POSTGRADO','2013-06-18 19:47:22','2013-06-18 19:51:15');
/*!40000 ALTER TABLE `grado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idioma`
--

DROP TABLE IF EXISTS `idioma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idioma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `codigo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idioma`
--

LOCK TABLES `idioma` WRITE;
/*!40000 ALTER TABLE `idioma` DISABLE KEYS */;
INSERT INTO `idioma` VALUES (1,'ESPAÑOL','es','2013-03-02 16:48:40','2013-03-08 20:17:32'),(2,'INGLES','en','2013-03-02 16:49:05','2013-03-13 03:41:00');
/*!40000 ALTER TABLE `idioma` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jurado`
--

DROP TABLE IF EXISTS `jurado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jurado` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `persona_id` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_jurado_on_persona_id` (`persona_id`),
  KEY `index_jurado_on_documento_id` (`documento_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jurado`
--

LOCK TABLES `jurado` WRITE;
/*!40000 ALTER TABLE `jurado` DISABLE KEYS */;
/*!40000 ALTER TABLE `jurado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mencion`
--

DROP TABLE IF EXISTS `mencion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mencion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `escuela_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mencion_on_escuela_id` (`escuela_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mencion`
--

LOCK TABLES `mencion` WRITE;
/*!40000 ALTER TABLE `mencion` DISABLE KEYS */;
INSERT INTO `mencion` VALUES (1,'BIOLOGIA CELULAR',1,'2013-03-02 23:43:13','2013-08-26 06:53:18'),(2,'BOTANICA',1,'2013-03-02 23:47:46','2013-03-02 23:47:46'),(3,'ECOLOGIA',1,'2013-03-02 23:48:13','2013-03-02 23:48:13'),(4,'TECNOLOGIA DE ALIMENTOS',1,'2013-03-02 23:48:43','2013-03-02 23:48:43'),(5,'ZOOLOGIA',1,'2013-03-02 23:49:12','2013-03-02 23:49:12'),(6,'APLICACIONES EN INTERNET',2,'2013-03-02 23:50:26','2013-08-26 03:06:51'),(7,'CALCULO CIENTIFICO',2,'2013-03-02 23:51:06','2013-03-02 23:51:06'),(8,'TECNOLOGIAS EN COMUNICACIONES Y REDES DE COMPUTADORAS',2,'2013-03-02 23:51:36','2013-08-26 03:05:29'),(9,'BASE DE DATOS',2,'2013-03-02 23:52:04','2013-08-26 03:08:59'),(10,'INGENIERIA DE SOFTWARE',2,'2013-03-02 23:53:21','2013-08-26 03:04:29'),(11,'INTELIGENCIA ARTIFICIAL',2,'2013-03-02 23:53:52','2013-03-02 23:53:52'),(12,'TECNOLOGIAS EDUCATIVAS',2,'2013-03-02 23:54:19','2013-03-02 23:55:07'),(13,'COMPUTACION GRAFICA',2,'2013-03-02 23:55:55','2013-03-02 23:55:55'),(14,'MODELOS MATEMATICOS',2,'2013-03-02 23:56:46','2013-08-26 03:02:59'),(15,'SISTEMAS DE INFORMACION',2,'2013-03-02 23:57:20','2013-03-02 23:57:20'),(16,'SISTEMAS DISTRIBUIDOS Y PARALELOS',2,'2013-03-02 23:59:45','2013-08-26 03:02:18'),(17,'SIN OPCION',1,'2013-08-26 03:01:06','2013-08-26 03:01:06'),(18,'SIN OPCION',2,'2013-08-26 03:15:04','2013-08-26 03:15:04'),(19,'ASTROFISICA',3,'2013-08-26 03:17:13','2013-08-26 03:17:13'),(20,'CIENCIA DE LOS MATERIALES',3,'2013-08-26 03:20:49','2013-08-26 03:20:49'),(21,'FISICA COMPUTACIONAL',3,'2013-08-26 03:21:31','2013-08-26 03:21:31'),(22,'FISICA EXPERIMENTAL',3,'2013-08-26 05:40:46','2013-08-26 05:40:46'),(23,'FISICA',3,'2013-08-26 05:41:38','2013-08-26 05:41:38'),(24,'FISICA MEDICA',3,'2013-08-26 05:43:21','2013-08-26 05:43:21'),(25,'FISICA TEORICA',3,'2013-08-26 05:44:01','2013-08-26 05:44:01'),(26,'GEOFISICA',3,'2013-08-26 05:44:49','2013-08-26 05:44:49'),(27,'INSTRUMENTACION',3,'2013-08-26 05:45:58','2013-08-26 05:45:58'),(28,'OCEANOGRAFIA',3,'2013-08-26 05:46:39','2013-08-26 05:46:39'),(29,'ESPECTROSCOPIA DE RESONANCIA MAGNETICA NUCLEAR',3,'2013-08-26 05:47:37','2013-08-26 05:47:37'),(30,'BASICA',6,'2013-08-26 05:49:11','2013-08-26 05:49:11'),(31,'GEOQUIMICA',6,'2013-08-26 05:49:48','2013-08-26 05:49:48'),(32,'TECNOLOGIA',6,'2013-08-26 05:50:21','2013-08-26 05:50:21');
/*!40000 ALTER TABLE `mencion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `persona` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cedula` char(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nombres` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `apellidos` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nombre_completo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persona`
--

LOCK TABLES `persona` WRITE;
/*!40000 ALTER TABLE `persona` DISABLE KEYS */;
/*!40000 ALTER TABLE `persona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `premio`
--

DROP TABLE IF EXISTS `premio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `premio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `premio`
--

LOCK TABLES `premio` WRITE;
/*!40000 ALTER TABLE `premio` DISABLE KEYS */;
INSERT INTO `premio` VALUES (1,'PREMIO ESPECIAL DE GRADUACION','2013-03-03 03:04:28','2013-03-03 03:15:47'),(2,'MAGNA CUM LAUDE','2013-03-03 03:04:52','2013-03-03 03:16:14'),(3,'SUMMA CUM LAUDE','2013-03-03 03:05:12','2013-03-03 03:16:28'),(4,'PREMIO ALTO RENDIMIENTO ACADEMICO','2013-07-10 01:04:51','2013-07-10 01:04:51');
/*!40000 ALTER TABLE `premio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reconocimiento`
--

DROP TABLE IF EXISTS `reconocimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reconocimiento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reconocimiento`
--

LOCK TABLES `reconocimiento` WRITE;
/*!40000 ALTER TABLE `reconocimiento` DISABLE KEYS */;
INSERT INTO `reconocimiento` VALUES (1,'MENCION HONORIFICA','2013-07-10 01:07:52','2013-07-10 01:07:52');
/*!40000 ALTER TABLE `reconocimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rindex`
--

DROP TABLE IF EXISTS `rindex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rindex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ocurrencia` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `termino_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rindex_on_documento_id` (`documento_id`),
  KEY `index_rindex_on_termino_id` (`termino_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rindex`
--

LOCK TABLES `rindex` WRITE;
/*!40000 ALTER TABLE `rindex` DISABLE KEYS */;
/*!40000 ALTER TABLE `rindex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20130302152652'),('20130302153236'),('20130302153633'),('20130302154430'),('20130302160331'),('20130302160817'),('20130302162856'),('20130302173606'),('20130302225257'),('20130302225451'),('20130302230313'),('20130302230855'),('20130302230856'),('20130303000805'),('20130303030137'),('20130303030138'),('20130303163425'),('20130303185657'),('20130303205324'),('20130303231810'),('20130303232350'),('20130304004311'),('20130304012340'),('20130304142800'),('20130304143158'),('20130304144059'),('20130304144311'),('20130304144338'),('20130305135141'),('20130305142252'),('20130306171420'),('20130307143710'),('20130307202942'),('20130309014234'),('20130505055223'),('20130509204915'),('20130613042041');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `termino`
--

DROP TABLE IF EXISTS `termino`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `termino` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `idioma_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_termino_on_idioma_id` (`idioma_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `termino`
--

LOCK TABLES `termino` WRITE;
/*!40000 ALTER TABLE `termino` DISABLE KEYS */;
/*!40000 ALTER TABLE `termino` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tindex`
--

DROP TABLE IF EXISTS `tindex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tindex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ocurrencia` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `termino_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tindex_on_documento_id` (`documento_id`),
  KEY `index_tindex_on_termino_id` (`termino_id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tindex`
--

LOCK TABLES `tindex` WRITE;
/*!40000 ALTER TABLE `tindex` DISABLE KEYS */;
INSERT INTO `tindex` VALUES (1,1,1,1,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(2,1,1,2,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(3,1,1,3,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(4,1,1,4,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(5,1,1,5,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(6,1,1,6,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(7,1,1,7,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(8,1,1,8,'2013-06-19 01:41:23','2013-06-19 01:41:23'),(9,1,2,2525,'2013-06-19 01:46:47','2013-06-19 01:46:47'),(10,1,2,2526,'2013-06-19 01:46:47','2013-06-19 01:46:47'),(11,1,2,244,'2013-06-19 01:46:47','2013-06-19 01:46:47'),(12,1,2,2527,'2013-06-19 01:46:47','2013-06-19 01:46:47'),(13,1,2,164,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(14,1,2,8,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(15,1,2,315,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(16,1,2,1104,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(17,1,2,1242,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(18,1,2,267,'2013-06-19 01:46:48','2013-06-19 01:46:48'),(19,1,3,183,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(20,1,3,1,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(21,1,3,355,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(22,1,3,206,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(23,1,3,8,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(24,1,3,14,'2013-06-19 01:52:50','2013-06-19 01:52:50'),(25,1,3,15,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(26,1,3,9,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(27,1,3,10,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(28,1,3,11,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(29,1,3,379,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(30,1,3,4076,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(31,1,3,2057,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(32,1,3,4077,'2013-06-19 01:52:51','2013-06-19 01:52:51'),(33,1,4,5519,'2013-06-19 01:59:12','2013-06-19 01:59:12'),(34,1,4,6050,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(35,1,4,684,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(36,1,4,4412,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(37,1,4,6051,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(38,1,4,1586,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(39,1,4,6052,'2013-06-19 01:59:13','2013-06-19 01:59:13'),(40,1,5,4581,'2013-06-19 02:06:19','2013-06-19 02:06:19'),(41,1,5,2793,'2013-06-19 02:06:19','2013-06-19 02:06:19'),(42,1,5,657,'2013-06-19 02:06:19','2013-06-19 02:06:19'),(43,1,5,747,'2013-06-19 02:06:19','2013-06-19 02:06:19'),(44,1,5,267,'2013-06-19 02:06:19','2013-06-19 02:06:19'),(45,1,5,7351,'2013-06-19 02:06:20','2013-06-19 02:06:20'),(46,1,5,7352,'2013-06-19 02:06:20','2013-06-19 02:06:20'),(47,1,6,248,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(48,1,6,507,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(49,1,6,1425,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(50,1,6,746,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(51,1,6,8920,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(52,1,6,5,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(53,1,6,5486,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(54,1,6,5548,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(55,1,6,12,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(56,1,6,13,'2013-06-19 02:13:48','2013-06-19 02:13:48'),(57,1,7,1719,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(58,1,7,9791,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(59,1,7,4076,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(60,1,7,9792,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(61,1,7,9793,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(62,1,7,9794,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(63,1,7,1794,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(64,1,7,9795,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(65,1,7,1085,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(66,1,7,1272,'2013-06-19 02:19:34','2013-06-19 02:19:34'),(67,1,8,11505,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(68,1,8,240,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(69,1,8,11506,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(70,1,8,719,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(71,1,8,3164,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(72,1,8,11507,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(73,1,8,11508,'2013-06-19 02:27:34','2013-06-19 02:27:34'),(74,1,8,11509,'2013-06-19 02:27:35','2013-06-19 02:27:35'),(75,1,8,11,'2013-06-19 02:27:35','2013-06-19 02:27:35'),(76,1,9,2470,'2013-06-20 16:56:09','2013-06-20 16:56:09'),(77,1,9,247,'2013-06-20 16:56:09','2013-06-20 16:56:09');
/*!40000 ALTER TABLE `tindex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_documento`
--

DROP TABLE IF EXISTS `tipo_documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipo_documento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `descripcion_corta` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_documento`
--

LOCK TABLES `tipo_documento` WRITE;
/*!40000 ALTER TABLE `tipo_documento` DISABLE KEYS */;
INSERT INTO `tipo_documento` VALUES (1,'TRABAJO ESPECIAL DE GRADO','TEG','2013-06-18 20:03:41','2013-06-18 20:03:41'),(2,'SEMINARIO','SEM','2013-06-18 20:05:06','2013-06-18 20:05:06'),(3,'NOTAS DE DOCENCIA','ND','2013-06-18 20:05:32','2013-06-18 20:05:32');
/*!40000 ALTER TABLE `tipo_documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tutor`
--

DROP TABLE IF EXISTS `tutor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tutor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `persona_id` int(11) DEFAULT NULL,
  `documento_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tutor_on_persona_id` (`persona_id`),
  KEY `index_tutor_on_documento_id` (`documento_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tutor`
--

LOCK TABLES `tutor` WRITE;
/*!40000 ALTER TABLE `tutor` DISABLE KEYS */;
/*!40000 ALTER TABLE `tutor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_usuario_on_nombre` (`nombre`),
  UNIQUE KEY `index_usuario_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'admin','admin@example.com','$2a$10$I.EjA1NYNF2J05j6WNqiS.IJM3.7V1m5688ZkVVhb33V14.QSiPqm',240,'2013-09-05 21:41:35','2013-09-05 20:08:31','192.168.1.101','127.0.0.1',0,NULL,NULL,'2013-03-09 16:53:38','2013-09-05 21:41:35');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visibilidad`
--

DROP TABLE IF EXISTS `visibilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visibilidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visibilidad`
--

LOCK TABLES `visibilidad` WRITE;
/*!40000 ALTER TABLE `visibilidad` DISABLE KEYS */;
INSERT INTO `visibilidad` VALUES (1,'PUBLICO','2013-06-18 20:12:43','2013-06-18 20:12:43'),(2,'PRIVADO','2013-06-18 20:13:08','2013-06-18 20:13:08');
/*!40000 ALTER TABLE `visibilidad` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-09-10 19:25:22
