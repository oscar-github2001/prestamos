/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: sessions
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblciudad
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblciudad` (
  `idciudad` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  `iddepartamentoFK` int(11) NOT NULL,
  PRIMARY KEY (`idciudad`),
  KEY `FK_TBLDEPARTAMENTO_TBLCIUDAD` (`iddepartamentoFK`),
  CONSTRAINT `FK_TBLDEPARTAMENTO_TBLCIUDAD` FOREIGN KEY (`iddepartamentoFK`) REFERENCES `tbldepartamento` (`iddepartamento`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblclientes
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblclientes` (
  `idcliente` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `sexo` char(1) NOT NULL CHECK (`sexo` in ('M', 'F')),
  `cedula` varchar(14) NOT NULL,
  `celular` varchar(11) NOT NULL,
  `direccion` varchar(150) NOT NULL,
  `usuario` varchar(25) NOT NULL,
  `contrasena` varchar(80) NOT NULL,
  `estado_civil` varchar(15) NOT NULL,
  `estado` char(1) NOT NULL DEFAULT '1',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `idciudadFK` int(11) NOT NULL,
  `idrolFK` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`idcliente`),
  KEY `FK_TBLCIUDAD_TBLCLIENTES` (`idciudadFK`),
  KEY `FK_TBLROLES_TBLCLIENTES` (`idrolFK`),
  CONSTRAINT `FK_TBLCIUDAD_TBLCLIENTES` FOREIGN KEY (`idciudadFK`) REFERENCES `tblciudad` (`idciudad`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLROLES_TBLCLIENTES` FOREIGN KEY (`idrolFK`) REFERENCES `tblroles` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblcuotas
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblcuotas` (
  `idcuota` int(11) NOT NULL AUTO_INCREMENT,
  `idprestamoFK` int(11) NOT NULL,
  `cuota` int(11) NOT NULL,
  `fecha_pago` date NOT NULL,
  `capital` decimal(10, 3) NOT NULL,
  `interescorriente` decimal(6, 3) NOT NULL,
  `abono` decimal(10, 3) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`idcuota`),
  KEY `FK_TBLPRESTAMOS_TBLCUOTAS` (`idprestamoFK`),
  CONSTRAINT `FK_TBLPRESTAMOS_TBLCUOTAS` FOREIGN KEY (`idprestamoFK`) REFERENCES `tblprestamos` (`idprestamo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 128 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tbldepartamento
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbldepartamento` (
  `iddepartamento` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `idpaisFK` int(11) NOT NULL,
  PRIMARY KEY (`iddepartamento`),
  KEY `FK_TBLPAIS_TBLDEPARTAMENTO` (`idpaisFK`),
  CONSTRAINT `FK_TBLPAIS_TBLDEPARTAMENTO` FOREIGN KEY (`idpaisFK`) REFERENCES `tblpais` (`idpais`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tbldescuento
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbldescuento` (
  `iddescuento` int(11) NOT NULL AUTO_INCREMENT,
  `descuento` decimal(10, 3) NOT NULL,
  `fecha_descuento` timestamp NOT NULL DEFAULT current_timestamp(),
  `idprestamoFK` int(11) NOT NULL,
  PRIMARY KEY (`iddescuento`),
  KEY `FK_TBLPRESTAMOS_TBLDESCUENTO` (`idprestamoFK`),
  CONSTRAINT `FK_TBLPRESTAMOS_TBLDESCUENTO` FOREIGN KEY (`idprestamoFK`) REFERENCES `tblprestamos` (`idprestamo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 25 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tbldetalle_cliente
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbldetalle_cliente` (
  `iddetallecliente` int(11) NOT NULL AUTO_INCREMENT,
  `trabajo` varchar(50) NOT NULL,
  `ocupacion` varchar(20) NOT NULL,
  `salario` varchar(10) NOT NULL,
  `telefono_trabajo` varchar(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `idclienteFK` int(11) NOT NULL,
  PRIMARY KEY (`iddetallecliente`),
  KEY `FK_TBLCLIENTES_TBLDETALLE_CLIENTE` (`idclienteFK`),
  CONSTRAINT `FK_TBLCLIENTES_TBLDETALLE_CLIENTE` FOREIGN KEY (`idclienteFK`) REFERENCES `tblclientes` (`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblformapago
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblformapago` (
  `idformapago` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(9) NOT NULL,
  PRIMARY KEY (`idformapago`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblintereses
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblintereses` (
  `idinteres` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` decimal(5, 3) NOT NULL,
  PRIMARY KEY (`idinteres`)
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblmoneda
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblmoneda` (
  `idmoneda` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(20) NOT NULL,
  `simbolo` varchar(10) NOT NULL,
  PRIMARY KEY (`idmoneda`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblpagos
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblpagos` (
  `idpago` int(11) NOT NULL AUTO_INCREMENT,
  `pago` decimal(10, 3) NOT NULL,
  `idcuotaFK` int(11) NOT NULL,
  `fecha_pago` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idpago`),
  KEY `FK_TBLCUOTAS_TBLPAGOS` (`idcuotaFK`),
  CONSTRAINT `FK_TBLCUOTAS_TBLPAGOS` FOREIGN KEY (`idcuotaFK`) REFERENCES `tblcuotas` (`idcuota`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 14 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblpais
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblpais` (
  `idpais` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`idpais`)
) ENGINE = InnoDB AUTO_INCREMENT = 6 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblprestamos
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblprestamos` (
  `idprestamo` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(4) NOT NULL,
  `idtipoprestamoFK` int(11) NOT NULL,
  `idclienteFK` int(11) NOT NULL,
  `idusuarioFK` int(11) NOT NULL,
  `idinteresFK` int(11) NOT NULL,
  `idformapagoFK` int(11) NOT NULL,
  `idmonedaFK` int(11) NOT NULL,
  `monto` decimal(10, 3) NOT NULL,
  `plazo` int(11) NOT NULL,
  `intereses` decimal(10, 3) NOT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_inicio` date GENERATED ALWAYS AS (`fecha_registro` + interval 1 month) VIRTUAL,
  `fecha_fin` date GENERATED ALWAYS AS (`fecha_registro` + interval `plazo` month) VIRTUAL,
  `estado` char(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idprestamo`),
  KEY `FK_TBLTIPOPRESTAMOS_TBLPRESTAMOS` (`idtipoprestamoFK`),
  KEY `FK_TBLCLIENTES_TBLPRESTAMOS` (`idclienteFK`),
  KEY `FK_TBLUSUARIOS_TBLPRESTAMOS` (`idusuarioFK`),
  KEY `FK_TBLINTERESES_TBLPRESTAMOS` (`idinteresFK`),
  KEY `FK_FORMAPAGO_TBLPRESTAMOS` (`idformapagoFK`),
  KEY `FK_TBLMONEDA_TBLPRESTAMOS` (`idmonedaFK`),
  CONSTRAINT `FK_FORMAPAGO_TBLPRESTAMOS` FOREIGN KEY (`idformapagoFK`) REFERENCES `tblformapago` (`idformapago`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLCLIENTES_TBLPRESTAMOS` FOREIGN KEY (`idclienteFK`) REFERENCES `tblclientes` (`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLINTERESES_TBLPRESTAMOS` FOREIGN KEY (`idinteresFK`) REFERENCES `tblintereses` (`idinteres`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLMONEDA_TBLPRESTAMOS` FOREIGN KEY (`idmonedaFK`) REFERENCES `tblmoneda` (`idmoneda`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLTIPOPRESTAMOS_TBLPRESTAMOS` FOREIGN KEY (`idtipoprestamoFK`) REFERENCES `tbltipoprestamos` (`idtipoprestamo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TBLUSUARIOS_TBLPRESTAMOS` FOREIGN KEY (`idusuarioFK`) REFERENCES `tblusuarios` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 20 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblroles
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblroles` (
  `idrol` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(50) NOT NULL,
  PRIMARY KEY (`idrol`)
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tbltipoprestamos
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbltipoprestamos` (
  `idtipoprestamo` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(60) NOT NULL,
  `estado` char(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idtipoprestamo`)
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblusuarios
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblusuarios` (
  `idusuario` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(50) NOT NULL,
  `contrasena` varchar(80) NOT NULL,
  `estado` char(1) NOT NULL DEFAULT '1',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `idrolFK` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`idusuario`),
  KEY `FK_TBLROLES_TBLUSUARIOS` (`idrolFK`),
  CONSTRAINT `FK_TBLROLES_TBLUSUARIOS` FOREIGN KEY (`idrolFK`) REFERENCES `tblroles` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: clientes_activos
# ------------------------------------------------------------

CREATE OR REPLACE VIEW `clientes_activos` AS
select
  `tblclientes`.`idcliente` AS `idcliente`,
  concat(
  `tblclientes`.`nombre`,
  ' ',
  `tblclientes`.`apellido`
  ) AS `nombre`
from
  `tblclientes`
where
  `tblclientes`.`estado` = 1;

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: sessions
# ------------------------------------------------------------

INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'P7PJXpDBMHd9cppGdC6gYeSZsbIzo5GM',
    1693263353,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"usuario\":1,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bzE_pwPY3A7ztiSPxSflJ2APaZldac0H',
    1693235019,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ujcUXQpkCMyAO8ER9z2p07KfIz-42wn-',
    1693156967,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uzOVoVPokjIsuUt8Z9pQEo2KbbSj6syQ',
    1693177201,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"usuario\":1,\"userId\":1,\"name\":\"oscar\"}'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblciudad
# ------------------------------------------------------------

INSERT INTO
  `tblciudad` (`idciudad`, `nombre`, `iddepartamentoFK`)
VALUES
  (1, 'Concepción', 1);
INSERT INTO
  `tblciudad` (`idciudad`, `nombre`, `iddepartamentoFK`)
VALUES
  (2, 'Masatepe', 1);
INSERT INTO
  `tblciudad` (`idciudad`, `nombre`, `iddepartamentoFK`)
VALUES
  (3, 'Nindirí', 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblclientes
# ------------------------------------------------------------

INSERT INTO
  `tblclientes` (
    `idcliente`,
    `nombre`,
    `apellido`,
    `fecha_nacimiento`,
    `sexo`,
    `cedula`,
    `celular`,
    `direccion`,
    `usuario`,
    `contrasena`,
    `estado_civil`,
    `estado`,
    `fecha_registro`,
    `idciudadFK`,
    `idrolFK`
  )
VALUES
  (
    1,
    'Eliezer  Javier',
    'Mercado Mercado',
    '2000-01-16',
    'm',
    '4011702021000I',
    '76889934',
    'Arena, 150mts al Norte',
    'eliezer@gmail.com',
    '$2a$10$720I2977smi5BIXyXP9Sh.68/gKN/YMcKB/TyUsTufSGEx4ALoSUa',
    'Soltero',
    '1',
    '2023-08-21 14:18:21',
    2,
    2
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblcuotas
# ------------------------------------------------------------

INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (1, 1, 1, '2023-07-20', 21.250, 16.150, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (2, 1, 2, '2023-08-20', 21.250, 14.131, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (3, 1, 3, '2023-09-20', 21.250, 12.113, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (4, 1, 4, '2023-10-20', 21.250, 10.094, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (5, 1, 5, '2023-11-20', 21.250, 8.075, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (6, 1, 6, '2023-12-20', 21.250, 6.056, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (7, 1, 7, '2024-01-20', 21.250, 4.038, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (8, 1, 8, '2024-02-20', 21.250, 2.019, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (9, 3, 1, '2022-02-01', 21.250, 16.150, 30.334, 2);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (10, 3, 2, '2022-03-01', 21.250, 14.131, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (11, 3, 3, '2022-04-01', 21.250, 12.113, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (12, 3, 4, '2022-05-01', 21.250, 10.094, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (13, 3, 5, '2022-06-01', 21.250, 8.075, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (14, 3, 6, '2022-07-01', 21.250, 6.056, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (15, 3, 7, '2022-08-01', 21.250, 4.038, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (16, 3, 8, '2022-09-01', 21.250, 2.019, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (17, 4, 1, '2023-09-26', 500.000, 237.500, 642.500, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (18, 4, 2, '2023-10-26', 500.000, 190.000, 642.500, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (19, 4, 3, '2023-11-26', 500.000, 142.500, 642.500, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (20, 4, 4, '2023-12-26', 500.000, 95.000, 642.500, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (21, 4, 5, '2024-01-26', 500.000, 47.500, 642.500, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (22, 5, 1, '2023-02-01', 21.250, 16.150, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (23, 5, 2, '2023-03-01', 21.250, 14.131, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (24, 5, 3, '2023-04-01', 21.250, 12.113, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (25, 5, 4, '2023-05-01', 21.250, 10.094, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (26, 5, 5, '2023-06-01', 21.250, 8.075, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (27, 5, 6, '2023-07-01', 21.250, 6.056, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (28, 5, 7, '2023-08-01', 21.250, 4.038, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (29, 5, 8, '2023-09-01', 21.250, 2.019, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (30, 6, 1, '2023-02-01', 21.250, 16.150, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (31, 6, 2, '2023-03-01', 21.250, 14.131, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (32, 6, 3, '2023-04-01', 21.250, 12.113, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (33, 6, 4, '2023-05-01', 21.250, 10.094, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (34, 6, 5, '2023-06-01', 21.250, 8.075, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (35, 6, 6, '2023-07-01', 21.250, 6.056, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (36, 6, 7, '2023-08-01', 21.250, 4.038, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (37, 6, 8, '2023-09-01', 21.250, 2.019, 30.334, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (38, 7, 1, '2023-02-01', 28.333, 16.150, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (39, 7, 2, '2023-03-01', 28.333, 13.458, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (40, 7, 3, '2023-04-01', 28.333, 10.767, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (41, 7, 4, '2023-05-01', 28.333, 8.075, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (42, 7, 5, '2023-06-01', 28.333, 5.383, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (43, 7, 6, '2023-07-01', 28.333, 2.692, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (44, 8, 1, '2023-03-01', 28.333, 16.150, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (45, 8, 2, '2023-04-01', 28.333, 13.458, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (46, 8, 3, '2023-05-01', 28.333, 10.767, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (47, 8, 4, '2023-06-01', 28.333, 8.075, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (48, 8, 5, '2023-07-01', 28.333, 5.383, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (49, 8, 6, '2023-08-01', 28.333, 2.692, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (50, 9, 1, '2023-04-02', 34.000, 16.150, 43.690, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (51, 9, 2, '2023-05-02', 34.000, 12.920, 43.690, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (52, 9, 3, '2023-06-02', 34.000, 9.690, 43.690, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (53, 9, 4, '2023-07-02', 34.000, 6.460, 43.690, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (54, 9, 5, '2023-08-02', 34.000, 3.230, 43.690, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (55, 10, 1, '2022-02-01', 155.500, 29.545, 177.659, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (56, 10, 2, '2022-03-01', 155.500, 14.773, 177.659, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (57, 11, 1, '2023-02-01', 28.333, 16.150, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (58, 11, 2, '2023-03-01', 28.333, 13.458, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (59, 11, 3, '2023-04-01', 28.333, 10.767, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (60, 11, 4, '2023-05-01', 28.333, 8.075, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (61, 11, 5, '2023-06-01', 28.333, 5.383, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (62, 11, 6, '2023-07-01', 28.333, 2.692, 37.754, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (63, 12, 1, '2023-02-01', 13.750, 5.225, 17.016, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (64, 12, 2, '2023-03-01', 13.750, 3.919, 17.016, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (65, 12, 3, '2023-04-01', 13.750, 2.613, 17.016, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (66, 12, 4, '2023-05-01', 13.750, 1.306, 17.016, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (67, 13, 1, '2023-04-01', 18.835, 7.157, 23.308, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (68, 13, 2, '2023-05-01', 18.835, 5.368, 23.308, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (69, 13, 3, '2023-06-01', 18.835, 3.579, 23.308, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (70, 13, 4, '2023-07-01', 18.835, 1.789, 23.308, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (71, 14, 1, '2022-02-01', 56.743, 16.172, 67.525, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (72, 14, 2, '2022-03-01', 56.743, 10.781, 67.525, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (73, 14, 3, '2022-04-01', 56.743, 5.391, 67.525, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (74, 15, 1, '2023-03-03', 56.667, 16.150, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (75, 15, 2, '2023-04-03', 56.667, 10.767, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (76, 15, 3, '2023-05-03', 56.667, 5.383, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (77, 16, 1, '2022-02-01', 13.565, 29.640, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (78, 16, 2, '2022-03-01', 13.565, 28.351, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (79, 16, 3, '2022-04-01', 13.565, 27.063, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (80, 16, 4, '2022-05-01', 13.565, 25.774, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (81, 16, 5, '2022-06-01', 13.565, 24.485, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (82, 16, 6, '2022-07-01', 13.565, 23.197, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (83, 16, 7, '2022-08-01', 13.565, 21.908, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (84, 16, 8, '2022-09-01', 13.565, 20.619, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (85, 16, 9, '2022-10-01', 13.565, 19.330, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (86, 16, 10, '2022-11-01', 13.565, 18.042, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (87, 16, 11, '2022-12-01', 13.565, 16.753, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (88, 16, 12, '2023-01-01', 13.565, 15.464, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (89, 16, 13, '2023-02-01', 13.565, 14.176, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (90, 16, 14, '2023-03-01', 13.565, 12.887, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (91, 16, 15, '2023-04-01', 13.565, 11.598, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (92, 16, 16, '2023-05-01', 13.565, 10.310, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (93, 16, 17, '2023-06-01', 13.565, 9.021, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (94, 16, 18, '2023-07-01', 13.565, 7.732, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (95, 16, 19, '2023-08-01', 13.565, 6.443, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (96, 16, 20, '2023-09-01', 13.565, 5.155, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (97, 16, 21, '2023-10-01', 13.565, 3.866, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (98, 16, 22, '2023-11-01', 13.565, 2.577, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (99, 16, 23, '2023-12-01', 13.565, 1.289, 29.030, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (100, 17, 1, '2023-02-01', 56.667, 16.150, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (101, 17, 2, '2023-03-01', 56.667, 10.767, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (102, 17, 3, '2023-04-01', 56.667, 5.383, 67.433, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (103, 18, 1, '2023-09-27', 150.000, 28.500, 171.375, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (104, 18, 2, '2023-10-27', 150.000, 14.250, 171.375, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (105, 19, 1, '2023-09-22', 4.348, 9.500, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (106, 19, 2, '2023-10-22', 4.348, 9.087, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (107, 19, 3, '2023-11-22', 4.348, 8.674, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (108, 19, 4, '2023-12-22', 4.348, 8.261, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (109, 19, 5, '2024-01-22', 4.348, 7.848, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (110, 19, 6, '2024-02-22', 4.348, 7.435, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (111, 19, 7, '2024-03-22', 4.348, 7.022, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (112, 19, 8, '2024-04-22', 4.348, 6.609, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (113, 19, 9, '2024-05-22', 4.348, 6.196, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (114, 19, 10, '2024-06-22', 4.348, 5.783, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (115, 19, 11, '2024-07-22', 4.348, 5.370, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (116, 19, 12, '2024-08-22', 4.348, 4.957, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (117, 19, 13, '2024-09-22', 4.348, 4.543, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (118, 19, 14, '2024-10-22', 4.348, 4.130, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (119, 19, 15, '2024-11-22', 4.348, 3.717, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (120, 19, 16, '2024-12-22', 4.348, 3.304, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (121, 19, 17, '2025-01-22', 4.348, 2.891, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (122, 19, 18, '2025-02-22', 4.348, 2.478, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (123, 19, 19, '2025-03-22', 4.348, 2.065, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (124, 19, 20, '2025-04-22', 4.348, 1.652, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (125, 19, 21, '2025-05-22', 4.348, 1.239, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (126, 19, 22, '2025-06-22', 4.348, 0.826, 9.304, 1);
INSERT INTO
  `tblcuotas` (
    `idcuota`,
    `idprestamoFK`,
    `cuota`,
    `fecha_pago`,
    `capital`,
    `interescorriente`,
    `abono`,
    `estado`
  )
VALUES
  (127, 19, 23, '2025-07-22', 4.348, 0.413, 9.304, 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tbldepartamento
# ------------------------------------------------------------

INSERT INTO
  `tbldepartamento` (`iddepartamento`, `nombre`, `idpaisFK`)
VALUES
  (1, 'Masaya', 1);
INSERT INTO
  `tbldepartamento` (`iddepartamento`, `nombre`, `idpaisFK`)
VALUES
  (2, 'Managua', 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tbldescuento
# ------------------------------------------------------------

INSERT INTO
  `tbldescuento` (
    `iddescuento`,
    `descuento`,
    `fecha_descuento`,
    `idprestamoFK`
  )
VALUES
  (24, 5.000, '2023-08-26 16:59:24', 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tbldetalle_cliente
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblformapago
# ------------------------------------------------------------

INSERT INTO
  `tblformapago` (`idformapago`, `descripcion`)
VALUES
  (1, 'Mensual');
INSERT INTO
  `tblformapago` (`idformapago`, `descripcion`)
VALUES
  (2, 'Quincenal');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblintereses
# ------------------------------------------------------------

INSERT INTO
  `tblintereses` (`idinteres`, `descripcion`)
VALUES
  (1, 9.500);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblmoneda
# ------------------------------------------------------------

INSERT INTO
  `tblmoneda` (`idmoneda`, `descripcion`, `simbolo`)
VALUES
  (1, 'Dólares', '$');
INSERT INTO
  `tblmoneda` (`idmoneda`, `descripcion`, `simbolo`)
VALUES
  (2, 'Córdobas', 'C$');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblpagos
# ------------------------------------------------------------

INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (1, 30.334, 1, '2023-08-26 16:58:21');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (2, 30.334, 2, '2023-08-26 16:58:31');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (3, 30.334, 3, '2023-08-26 16:58:31');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (4, 30.334, 4, '2023-08-26 16:58:31');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (5, 8.998, 5, '2023-08-26 16:58:31');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (6, 21.336, 5, '2023-08-26 16:58:38');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (7, 30.334, 6, '2023-08-26 16:58:38');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (8, 30.334, 7, '2023-08-26 16:58:38');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (9, 17.996, 8, '2023-08-26 16:58:38');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (10, 5.000, 8, '2023-08-26 16:58:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (11, 2.338, 8, '2023-08-26 16:59:08');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (12, 5.000, 8, '2023-08-26 16:59:24');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (13, 30.334, 9, '2023-08-27 09:43:38');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblpais
# ------------------------------------------------------------

INSERT INTO
  `tblpais` (`idpais`, `nombre`)
VALUES
  (1, 'Nicaragua');
INSERT INTO
  `tblpais` (`idpais`, `nombre`)
VALUES
  (2, 'Costa Rica');
INSERT INTO
  `tblpais` (`idpais`, `nombre`)
VALUES
  (4, 'Estados Unidos');
INSERT INTO
  `tblpais` (`idpais`, `nombre`)
VALUES
  (5, 'Honduras');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblprestamos
# ------------------------------------------------------------

INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    1,
    '0001',
    1,
    1,
    2,
    1,
    1,
    1,
    170.000,
    8,
    72.675,
    '2023-06-20',
    '2023-07-20',
    '2024-02-20',
    '0'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    2,
    '0002',
    1,
    1,
    1,
    1,
    1,
    2,
    2500.000,
    4,
    593.750,
    '0000-00-00',
    NULL,
    NULL,
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    3,
    '0003',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    8,
    72.675,
    '2022-01-01',
    '2022-02-01',
    '2022-09-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    4,
    '0004',
    1,
    1,
    1,
    1,
    1,
    2,
    2500.000,
    5,
    712.500,
    '2023-08-26',
    '2023-09-26',
    '2024-01-26',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    5,
    '0005',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    8,
    72.675,
    '2023-01-01',
    '2023-02-01',
    '2023-09-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    6,
    '0006',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    8,
    72.675,
    '2023-01-01',
    '2023-02-01',
    '2023-09-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    7,
    '0007',
    2,
    1,
    1,
    1,
    1,
    1,
    170.000,
    6,
    56.525,
    '2023-01-01',
    '2023-02-01',
    '2023-07-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    8,
    '0008',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    6,
    56.525,
    '2023-02-01',
    '2023-03-01',
    '2023-08-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    9,
    '0009',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    5,
    48.450,
    '2023-03-02',
    '2023-04-02',
    '2023-08-02',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    10,
    '0010',
    1,
    1,
    1,
    1,
    1,
    1,
    311.000,
    2,
    44.318,
    '2022-01-01',
    '2022-02-01',
    '2022-03-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    11,
    '0011',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    6,
    56.525,
    '2023-01-01',
    '2023-02-01',
    '2023-07-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    12,
    '0012',
    1,
    1,
    1,
    1,
    1,
    1,
    55.000,
    4,
    13.063,
    '2023-01-01',
    '2023-02-01',
    '2023-05-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    13,
    '0013',
    1,
    1,
    1,
    1,
    1,
    1,
    75.340,
    4,
    17.893,
    '2023-03-01',
    '2023-04-01',
    '2023-07-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    14,
    '0014',
    1,
    1,
    1,
    1,
    1,
    1,
    170.230,
    3,
    32.344,
    '2022-01-01',
    '2022-02-01',
    '2022-04-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    15,
    '0015',
    1,
    1,
    1,
    1,
    1,
    1,
    170.000,
    3,
    32.300,
    '2023-02-03',
    '2023-03-03',
    '2023-05-03',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    16,
    '0016',
    1,
    1,
    1,
    1,
    1,
    1,
    312.000,
    23,
    355.680,
    '2022-01-01',
    '2022-02-01',
    '2023-12-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    17,
    '0017',
    2,
    1,
    1,
    1,
    1,
    1,
    170.000,
    3,
    32.300,
    '2023-01-01',
    '2023-02-01',
    '2023-04-01',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    18,
    '0018',
    1,
    1,
    1,
    1,
    1,
    1,
    300.000,
    2,
    42.750,
    '2023-08-27',
    '2023-09-27',
    '2023-10-27',
    '1'
  );
INSERT INTO
  `tblprestamos` (
    `idprestamo`,
    `codigo`,
    `idtipoprestamoFK`,
    `idclienteFK`,
    `idusuarioFK`,
    `idinteresFK`,
    `idformapagoFK`,
    `idmonedaFK`,
    `monto`,
    `plazo`,
    `intereses`,
    `fecha_registro`,
    `fecha_inicio`,
    `fecha_fin`,
    `estado`
  )
VALUES
  (
    19,
    '0019',
    1,
    1,
    1,
    1,
    1,
    1,
    100.000,
    23,
    114.000,
    '2023-08-22',
    '2023-09-22',
    '2025-07-22',
    '1'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblroles
# ------------------------------------------------------------

INSERT INTO
  `tblroles` (`idrol`, `descripcion`)
VALUES
  (1, 'administrador');
INSERT INTO
  `tblroles` (`idrol`, `descripcion`)
VALUES
  (2, 'cliente');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tbltipoprestamos
# ------------------------------------------------------------

INSERT INTO
  `tbltipoprestamos` (`idtipoprestamo`, `descripcion`, `estado`)
VALUES
  (1, 'Prestamos personales', '1');
INSERT INTO
  `tbltipoprestamos` (`idtipoprestamo`, `descripcion`, `estado`)
VALUES
  (2, 'Financiamiento de Teléfono', '1');
INSERT INTO
  `tbltipoprestamos` (`idtipoprestamo`, `descripcion`, `estado`)
VALUES
  (3, 'Otro', '0');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblusuarios
# ------------------------------------------------------------

INSERT INTO
  `tblusuarios` (
    `idusuario`,
    `usuario`,
    `contrasena`,
    `estado`,
    `fecha_registro`,
    `idrolFK`
  )
VALUES
  (
    1,
    'oscar',
    '$2a$10$ZK5xPa3ccIXx8KcYHKxbR.x/LlGC4OJZ96/lDq46G.ogoE6fiHaeu',
    '1',
    '2023-05-31 13:32:27',
    1
  );
INSERT INTO
  `tblusuarios` (
    `idusuario`,
    `usuario`,
    `contrasena`,
    `estado`,
    `fecha_registro`,
    `idrolFK`
  )
VALUES
  (
    2,
    'admin',
    '$2a$10$AiY1b3ERZYas5/xm6s.dE.tUSdysGFTzTBTfxVffgBIH4EWIvIK.W',
    '1',
    '2023-08-21 13:51:20',
    1
  );
INSERT INTO
  `tblusuarios` (
    `idusuario`,
    `usuario`,
    `contrasena`,
    `estado`,
    `fecha_registro`,
    `idrolFK`
  )
VALUES
  (
    3,
    'cliente',
    '$2a$10$nSbSkVYHJqGYOy1BGlajl.4g1dgyr8u.ayjk3/kv4sBzeTiFD6VGS',
    '1',
    '2023-08-27 13:00:08',
    1
  );

# ------------------------------------------------------------
# TRIGGER DUMP FOR: act_estado_prestamo
# ------------------------------------------------------------

DROP TRIGGER IF EXISTS act_estado_prestamo;
DELIMITER ;;
CREATE TRIGGER act_estado_prestamo
AFTER UPDATE ON tblcuotas
FOR EACH ROW
BEGIN
    DECLARE prestamo_pagado VARCHAR(3);
    SELECT 
        IF(
            COUNT(C1.idcuota) = (SELECT COUNT(C2.idcuota)
                                FROM tblcuotas AS C2
                                WHERE C2.idprestamoFK = NEW.idprestamoFK), 'SI', 'NO') INTO prestamo_pagado
    FROM tblcuotas AS C1
    WHERE C1.idprestamoFK = NEW.idprestamoFK AND C1.estado = 2;
    
    IF prestamo_pagado = 'SI' THEN
        UPDATE tblprestamos
        SET estado = 0
        WHERE idprestamo = new.idprestamoFK;
    END IF;
END;;
DELIMITER ;

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
