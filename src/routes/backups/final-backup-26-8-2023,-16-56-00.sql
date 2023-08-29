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
) ENGINE = InnoDB AUTO_INCREMENT = 22 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 24 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
    'ujcUXQpkCMyAO8ER9z2p07KfIz-42wn-',
    1693156967,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uzOVoVPokjIsuUt8Z9pQEo2KbbSj6syQ',
    1693176839,
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
  (1, 1, 1, '2023-07-20', 21.250, 16.150, 30.334, 1);
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
  (2, 1, 2, '2023-08-20', 21.250, 14.131, 30.334, 1);
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
  (3, 1, 3, '2023-09-20', 21.250, 12.113, 30.334, 1);
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
  (4, 1, 4, '2023-10-20', 21.250, 10.094, 30.334, 1);
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
  (5, 1, 5, '2023-11-20', 21.250, 8.075, 30.334, 1);
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
  (6, 1, 6, '2023-12-20', 21.250, 6.056, 30.334, 1);
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
  (7, 1, 7, '2024-01-20', 21.250, 4.038, 30.334, 1);
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
  (8, 1, 8, '2024-02-20', 21.250, 2.019, 30.334, 1);
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
  (9, 3, 1, '2022-02-01', 21.250, 16.150, 30.334, 1);
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
