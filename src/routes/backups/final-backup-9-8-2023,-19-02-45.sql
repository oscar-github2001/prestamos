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
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblpais
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblpais` (
  `idpais` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`idpais`)
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tblroles
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tblroles` (
  `idrol` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(50) NOT NULL,
  PRIMARY KEY (`idrol`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

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
    'A8Jp1kyyJdFikJ9PKgi73N4ymXFzvoLW',
    1691453413,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'HQdcOxCXYLK1nGwCgxJjM-id9kQj9gsh',
    1691372265,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Hv-AJ2pnnL6SpBa82b8G4YphtvWDvCrx',
    1691025896,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cNicGt-r89o4P0aPbHEoLavbPpLzdsqE',
    1691107817,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'e8SwEhElrHA_W1VFdXmyV1l9sh4AsUzS',
    1691441307,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ki5xtCvC4e8CMwWk6V6gc671Ubg3ijOm',
    1691290582,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'piw1Iy4Opum7Leq3CCdzLzMALJsPjJBV',
    1691715764,
    '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"loggedin\":true,\"userId\":1,\"name\":\"oscar\"}'
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
    'Juan Andréz',
    'Cerda Mercado',
    '1996-07-27',
    'm',
    '4011702021000I',
    '78989922',
    'Masatepe, parque central 150mts al Sur',
    'jose@gmail.com',
    '$2a$10$FvdIgOzYlVsnHcRQNZLqIOe7Xj6S1gDwfSqGF88d0PD5g.fpZXc1i',
    'Soltero',
    '1',
    '2023-07-17 13:45:44',
    2,
    2
  );
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
    2,
    'Marcos Alonso',
    'Alemán Moya',
    '1990-07-25',
    'f',
    '4011602021000L',
    '78657790',
    'Linda vista, calle 2',
    'luz@gmail.com',
    '$2a$10$.4Hf1jp4uCo74fZiTTCC0u91ETePCtDaJAj7hu51O7RrFS7r2P8de',
    'Soltero',
    '1',
    '2023-07-17 13:56:34',
    2,
    2
  );
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
    3,
    'Gonzalo Higuain',
    'Cerda Velásquez',
    '1990-07-26',
    'm',
    '4011602021000J',
    '78663422',
    'De la escuela de la cruz de mayo, 10 vrs al Sur',
    'marcos@gmail.com',
    '$2a$10$vHZy.sxxzKqQg4k3gpCdfe4G1vesq3qg3da7dZ9PZgzjV25QVHjbW',
    'Casado',
    '1',
    '2023-07-17 13:58:56',
    1,
    2
  );
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
    4,
    'Hortensio Guadamuz',
    'Ortiz Aguirre',
    '1980-02-12',
    'm',
    '4011602021000J',
    '78621233',
    'Centro de salud central, 20 mts al Norte',
    'hortencio@gmail.com',
    '$2a$10$25Wxdpkdt/tQX7PLOrSRuOaGsgqd0EdTHLm6OJ4pLJGZBMOC1D4V.',
    'Soltero',
    '1',
    '2023-07-27 17:06:03',
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
  (1, 1, 1, '2023-07-16', 21.250, 16.150, 30.334, 2);
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
  (2, 1, 2, '2023-08-16', 21.250, 14.131, 30.334, 2);
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
  (3, 1, 3, '2023-09-16', 21.250, 12.113, 30.334, 2);
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
  (4, 1, 4, '2023-10-16', 21.250, 10.094, 30.334, 2);
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
  (5, 1, 5, '2023-11-16', 21.250, 8.075, 30.334, 2);
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
  (6, 1, 6, '2023-12-16', 21.250, 6.056, 30.334, 2);
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
  (7, 1, 7, '2024-01-16', 21.250, 4.038, 30.334, 2);
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
  (8, 1, 8, '2024-02-16', 21.250, 2.019, 30.334, 2);

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

INSERT INTO
  `tbldetalle_cliente` (
    `iddetallecliente`,
    `trabajo`,
    `ocupacion`,
    `salario`,
    `telefono_trabajo`,
    `fecha_inicio`,
    `fecha_fin`,
    `idclienteFK`
  )
VALUES
  (
    5,
    'Casa en Managua',
    'Médico',
    '7000',
    '89785688',
    '2021-01-01',
    '2022-06-25',
    4
  );

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
  (1, 30.334, 1, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (2, 30.334, 2, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (3, 30.334, 3, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (4, 30.334, 4, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (5, 30.334, 5, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (6, 30.334, 6, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (7, 30.334, 7, '2023-08-04 20:54:49');
INSERT INTO
  `tblpagos` (`idpago`, `pago`, `idcuotaFK`, `fecha_pago`)
VALUES
  (8, 30.334, 8, '2023-08-04 20:54:49');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tblpais
# ------------------------------------------------------------

INSERT INTO
  `tblpais` (`idpais`, `nombre`)
VALUES
  (1, 'Nicaragua');

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
    2,
    1,
    1,
    1,
    1,
    170.000,
    8,
    72.675,
    '2023-06-16',
    '2023-07-16',
    '2024-02-16',
    '0'
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
