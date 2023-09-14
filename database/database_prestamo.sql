CREATE DATABASE Final;

-- Seleccionar la base de datos 'Loan' para su uso
USE Final;

-- Tabla Roles
CREATE TABLE TBLROLES
(
    idrol          INT NOT NULL AUTO_INCREMENT,
    descripcion    VARCHAR(50) NOT NULL,
    PRIMARY KEY    (idrol)
);


-- Tabla Usuarios
CREATE TABLE TBLUSUARIOS
(
    idusuario        INT NOT NULL AUTO_INCREMENT,
    usuario           VARCHAR(50) NOT NULL,
    contrasena       VARCHAR(80) NOT NULL,
    estado           CHAR(1) NOT NULL DEFAULT 1,
    fecha_registro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idrolFK          INT NOT NULL DEFAULT 1,
    PRIMARY KEY      (idusuario),
    CONSTRAINT       FK_TBLROLES_TBLUSUARIOS
        FOREIGN KEY  (idrolFK)
        REFERENCES   TBLROLES(idrol)
        ON DELETE    CASCADE    
        ON UPDATE    CASCADE
);

-- Tabla país
CREATE TABLE TBLPAIS
(
    idpais          INT NOT NULL AUTO_INCREMENT,
    nombre             VARCHAR(50) NOT NULL,
    PRIMARY KEY     (idpais)
);

-- Tabla Departamento
CREATE TABLE TBLDEPARTAMENTO
(
    iddepartamento   INT NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    idpaisFK         INT NOT NULL,
    PRIMARY KEY      (iddepartamento),
    CONSTRAINT       FK_TBLPAIS_TBLDEPARTAMENTO
        FOREIGN KEY  (idpaisFK)
        REFERENCES   TBLPAIS(idpais)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE
);

-- Tabla Ciudad
CREATE TABLE TBLCIUDAD
(
    idciudad         INT NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(60) NOT NULL,
    iddepartamentoFK INT NOT NULL,
    PRIMARY KEY      (idciudad),
    CONSTRAINT       FK_TBLDEPARTAMENTO_TBLCIUDAD
        FOREIGN KEY  (iddepartamentoFK)
        REFERENCES   TBLDEPARTAMENTO(iddepartamento)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE
);

-- Tabla Clientes
CREATE TABLE TBLCLIENTES
(
    idcliente        INT NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    apellido         VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo             CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    cedula           VARCHAR(14) NOT NULL,
    celular          VARCHAR(11) NOT NULL,
    direccion        VARCHAR(150) NOT NULL,
    usuario          VARCHAR(25) NOT NULL,
    contrasena       VARCHAR(80) NOT NULL,
    estado_civil     VARCHAR(15) NOT NULL,
    estado           CHAR(1) NOT NULL DEFAULT 1,
    fecha_registro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idciudadFK       INT NOT NULL,
    idrolFK          INT NOT NULL DEFAULT 2,
    PRIMARY KEY(idcliente),
    CONSTRAINT       FK_TBLCIUDAD_TBLCLIENTES
        FOREIGN KEY  (idciudadFK)
        REFERENCES   TBLCIUDAD(idciudad)
        ON DELETE    CASCADE    
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_TBLROLES_TBLCLIENTES
        FOREIGN KEY  (idrolFK)
        REFERENCES   TBLROLES(idrol)
        ON DELETE    CASCADE    
        ON UPDATE    CASCADE
);


-- Tabla Detalle Cliente
CREATE TABLE TBLDETALLE_CLIENTE
(
    iddetallecliente    INT NOT NULL AUTO_INCREMENT,
    trabajo             VARCHAR(50) NOT NULL,
    ocupacion           VARCHAR(20) NOT NULL,
    salario             VARCHAR(10) NOT NULL,
    telefono_trabajo    VARCHAR(11) NOT NULL,
    fecha_inicio        DATE NOT NULL,
    fecha_fin           DATE NOT NULL,
    idclienteFK         INT NOT NULL,
    PRIMARY KEY         (iddetallecliente),
    CONSTRAINT          FK_TBLCLIENTES_TBLDETALLE_CLIENTE
        FOREIGN KEY     (idclienteFK)
        REFERENCES      TBLCLIENTES(idcliente)
        ON DELETE       CASCADE
        ON UPDATE       CASCADE
);

-- Tabla Tipo de Prestamos
CREATE TABLE TBLTIPOPRESTAMOS
(
    idtipoprestamo      INT NOT NULL AUTO_INCREMENT,
    descripcion         VARCHAR(60) NOT NULL,
    estado              CHAR(1) NOT NULL DEFAULT 1,
    PRIMARY KEY         (idtipoprestamo)
);

-- Tabla Foma de Pago
CREATE TABLE TBLFORMAPAGO
(
    idformapago        INT NOT NULL AUTO_INCREMENT,
    descripcion        VARCHAR(9) NOT NULL,
    PRIMARY KEY        (idformapago)
);

CREATE TABLE TBLMONEDA
(
    idmoneda           INT NOT NULL AUTO_INCREMENT,
    descripcion        VARCHAR(20) NOT NULL,
    simbolo            VARCHAR(10) NOT NULL,
    PRIMARY KEY        (idmoneda)
);

-- Tabla Intereses
CREATE TABLE TBLINTERESES
(
    idinteres         INT NOT NULL AUTO_INCREMENT,
    descripcion       NUMERIC(5,3) NOT NULL,
    PRIMARY KEY       (idinteres)
);


-- Tabla Prestamos 
CREATE TABLE TBLPRESTAMOS
(
    idprestamo       INT NOT NULL AUTO_INCREMENT,
    codigo           VARCHAR(4) NOT NULL,
    idtipoprestamoFK INT NOT NULL,
    idclienteFK      INT NOT NULL,
    idusuarioFK      INT NOT NULL,
    idinteresFK      INT NOT NULL,
    idformapagoFK    INT NOT NULL,
    idmonedaFK       INT NOT NULL,
    monto            NUMERIC(10,3) NOT NULL,
    plazo            INT NOT NULL,
    intereses        NUMERIC(10,3) NOT NULL,
    -- fecha_registro   DATE DEFAULT CURRENT_DATE,
    -- fecha_registro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_registro   DATE,
    fecha_inicio     DATE GENERATED ALWAYS AS (DATE_ADD(fecha_registro, INTERVAL 1 MONTH)),
    fecha_fin        DATE GENERATED ALWAYS AS (DATE_ADD(fecha_registro, INTERVAL plazo MONTH)),
    estado           CHAR(1)  NOT NULL DEFAULT 1,
    PRIMARY KEY      (idprestamo),
    CONSTRAINT       FK_TBLTIPOPRESTAMOS_TBLPRESTAMOS
        FOREIGN KEY  (idtipoprestamoFK)
        REFERENCES   TBLTIPOPRESTAMOS(idtipoprestamo)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_TBLCLIENTES_TBLPRESTAMOS
        FOREIGN KEY  (idclienteFK)
        REFERENCES   TBLCLIENTES(idcliente)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_TBLUSUARIOS_TBLPRESTAMOS
        FOREIGN KEY  (idusuarioFK)
        REFERENCES   TBLUSUARIOS(idusuario)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_TBLINTERESES_TBLPRESTAMOS
        FOREIGN KEY  (idinteresFK)
        REFERENCES   TBLINTERESES(idinteres)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_FORMAPAGO_TBLPRESTAMOS
        FOREIGN KEY  (idformapagoFK)
        REFERENCES   TBLFORMAPAGO(idformapago)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE,
    CONSTRAINT       FK_TBLMONEDA_TBLPRESTAMOS
        FOREIGN KEY  (idmonedaFK)
        REFERENCES   TBLMONEDA(idmoneda)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE
);

-- Tabla Cuotas
CREATE TABLE TBLCUOTAS
(
    idcuota          INT NOT NULL AUTO_INCREMENT,
    idprestamoFK     INT NOT NULL,
    cuota            INT NOT NULL,
    fecha_pago       DATE NOT NULL,
    capital          NUMERIC(10,3) NOT NULL,
    interescorriente NUMERIC(10,3) NOT NULL,
    -- interesmoratorio NUMERIC(6,3) NOT NULL,
    abono            NUMERIC(10,3) NOT NULL,
    estado           INT NOT NULL DEFAULT 1,
    PRIMARY KEY     (idcuota),
    CONSTRAINT       FK_TBLPRESTAMOS_TBLCUOTAS
        FOREIGN KEY  (idprestamoFK)
        REFERENCES   TBLPRESTAMOS(idprestamo)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE 
);

CREATE TABLE TBLPAGOS
(
    idpago           INT NOT NULL AUTO_INCREMENT,
    pago             NUMERIC(10,3) NOT NULL,
    fecha_pago       TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    idcuotaFK        INT NOT NULL,
    PRIMARY KEY      (idpago),
     CONSTRAINT       FK_TBLCUOTAS_TBLPAGOS
        FOREIGN KEY  (idcuotaFK)
        REFERENCES   TBLCUOTAS(idcuota)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE 
);

CREATE TABLE TBLDESCUENTO
(
    iddescuento           INT NOT NULL AUTO_INCREMENT,
    descuento             NUMERIC(10,3) NOT NULL,
    fecha_descuento       TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    idprestamoFK          INT NOT NULL,
    PRIMARY KEY      (iddescuento),
    CONSTRAINT       FK_TBLPRESTAMOS_TBLDESCUENTO
        FOREIGN KEY  (idprestamoFK)
        REFERENCES   TBLPRESTAMOS(idprestamo)
        ON DELETE    CASCADE
        ON UPDATE    CASCADE 
);
--USE Final;

-- Procedimientos almacenados
-- PA INSERTAR
-- Insertar prestamos
DELIMITER $$
CREATE PROCEDURE pa_insertar_prestamos(
    IN _codigo           VARCHAR(4),
    IN _idtipoprestamoFK INT,
    IN _idclienteFK      INT,
    IN _idusuarioFK      INT,
    IN _idinteresFK      INT,
    IN _idformapagoFK    INT,
    IN _monto            NUMERIC(10,3),
    IN _plazo            INT,
    IN _intereses        NUMERIC(10,3),
    IN _idmonedaFK       INT,
    IN _fecha_registro   DATE
)BEGIN
    INSERT INTO tblprestamos (  
            codigo,
            idtipoprestamoFK,
            idclienteFK, 
            idusuarioFK, 
            idinteresFK, 
            idformapagoFK, 
            monto, 
            plazo,
            intereses,
            idmonedaFK,
            fecha_registro) 
    VALUES (
        _codigo,
        _idtipoprestamoFK,
        _idclienteFK,
        _idusuarioFK,
        _idinteresFK,
        _idformapagoFK,
        _monto,
        _plazo,
        _intereses,
        _idmonedaFK,
        _fecha_registro 
    );
      SELECT LAST_INSERT_ID() AS obt_id;
END$$
-- Insertar usuarios
DELIMITER $$
CREATE PROCEDURE pa_insertar_usuarios(
        IN _usuario       VARCHAR(50),
        IN _contrasena   VARCHAR(80))
BEGIN
    INSERT INTO tblusuarios(
        usuario,
        contrasena)
    VALUES(
        _usuario,
        _contrasena);
END$$

-- Insertar clientes
DELIMITER $$
CREATE PROCEDURE pa_insertar_clientes (
    IN _nombre           VARCHAR(50),
    IN _apellido         VARCHAR(50),
    IN _fecha_nacimiento DATE,
    IN _sexo             CHAR(1),
    IN _cedula           VARCHAR(14),
    IN _celular          VARCHAR(11),
    IN _direccion        VARCHAR(150),
    IN _usuario          VARCHAR(25),
    IN _contrasena       VARCHAR(80),
    IN _estado_civil     VARCHAR(15),
    IN _idciudadFK       INT
)
BEGIN
    INSERT INTO tblclientes (
        nombre, 
        apellido, 
        fecha_nacimiento,
        sexo,
        cedula,
        celular,
        direccion,
        usuario,
        contrasena,
        estado_civil, 
        idciudadFK) 
    VALUES (
        _nombre, 
        _apellido, 
        _fecha_nacimiento,
        _sexo,
        _cedula,
        _celular,
        _direccion,
        _usuario,
        _contrasena,
        _estado_civil,
        _idciudadFK);
END$$

-- Insertar cuotas
DELIMITER $$
CREATE PROCEDURE pa_insertar_cuotas(
    IN _idprestamoFK     INT,
    IN _cuota            INT,
    IN _fecha_pago       DATE,
    IN _capital          NUMERIC(10,3),
    IN _interescorriente NUMERIC(10,3),
    IN _abono            NUMERIC(10,3)
)
BEGIN
    INSERT INTO tblcuotas (
            idprestamoFK,
            cuota,
            fecha_pago,
            capital,
            interescorriente,
            abono)
    VALUES (
        _idprestamoFK,
        _cuota,
        _fecha_pago,
        _capital,
        _interescorriente,
        _abono);
END$$

-- Insertar pagos
DELIMITER $$
CREATE PROCEDURE pa_insertar_pagos(
    IN _pago          NUMERIC(10,3),
    IN _idcuotaFK     INT
)BEGIN
    INSERT INTO tblpagos 
        (pago, 
        idcuotaFK)
    VALUES (
        _pago,
        _idcuotaFK
    );
END$$

-- PA ACTUALIZAR
-- Cambiar estado de los tipos de prestamos
DELIMITER //
CREATE PROCEDURE pa_actualizar_tipoprestamo_estado(
                               IN _idtipoprestamo INT        
                              )
BEGIN
    DECLARE obt_estado CHAR(1);
    SELECT
        IF(estado = 1, 0, 1) INTO obt_estado
    FROM tbltipoprestamos
    WHERE idtipoprestamo = _idtipoprestamo;

    UPDATE tbltipoprestamos
    SET estado = obt_estado
    WHERE idtipoprestamo = _idtipoprestamo;
 END //


-- Actualizar estado de la cuota
DELIMITER //
CREATE PROCEDURE pa_actualizar_cuotas_estado(
                               IN _idcuota INT,
                               IN _estado CHAR(1)          
                              )
BEGIN
      UPDATE tblcuotas
      SET estado=_estado
      WHERE idcuota = _idcuota;
 END //

-- Actualizar estado de los prestamos
DELIMITER //
CREATE PROCEDURE pa_actualizar_prestamos_estado(
                               IN _idprestamo INT,
                               IN _estado CHAR(1)          
                              )
BEGIN
      UPDATE tblprestamos
      SET estado=_estado
      WHERE idprestamo = _idprestamo;
END //

--Cambiar estado de los usuarios
DELIMITER //
CREATE PROCEDURE pa_actualizar_usuario_estado(
                               IN _idusuario INT       
                              )
BEGIN
    DECLARE obt_estado CHAR(1);
    SELECT
        IF(estado = 1, 0, 1) INTO obt_estado
    FROM tblusuarios
    WHERE idusuario = _idusuario;

    UPDATE tblusuarios
    SET estado = obt_estado
    WHERE idusuario = _idusuario;
 END //

--Cambiar estado de los clientes
DELIMITER //
CREATE PROCEDURE pa_actualizar_cliente_estado(
                               IN _idcliente INT     
                              )
BEGIN
        DECLARE obt_estado CHAR(1);
        SELECT
            IF(estado = 1, 0, 1) INTO obt_estado
        FROM tblclientes
        WHERE idcliente = _idcliente;

        UPDATE tblclientes
        SET estado = obt_estado
        WHERE idcliente = _idcliente;
 END //

-- Actualizar clientes
DELIMITER //
CREATE PROCEDURE pa_actualizar_cliente(
    IN _idcliente        INT,
    IN _nombre           VARCHAR(50),
    IN _apellido         VARCHAR(50),
    IN _fecha_nacimiento DATE,
    IN _sexo             CHAR(1),
    IN _cedula           VARCHAR(14),
    IN _celular           VARCHAR(11),
    IN _direccion        VARCHAR(150),
    IN _usuario          VARCHAR(25),
    IN _estado_civil     VARCHAR(15),
    IN _idciudadFK       INT )
BEGIN 
    UPDATE tblclientes
    SET nombre = _nombre,
        apellido = _apellido,
        fecha_nacimiento = _fecha_nacimiento,
        sexo = _sexo,
        cedula = _cedula, 
        celular = _celular,
        direccion = _direccion,
        usuario = _usuario,
        estado_civil = _estado_civil,
        idciudadFK = _idciudadFK
    WHERE idcliente = _idcliente;
END //

-- Actualizar datos de los préstamos
DELIMITER //

CREATE PROCEDURE pa_actualizar_prestamos (
    IN _idprestamo          INT,
    IN _idcliente           INT,
    IN _idtipoprestamo      INT,
    IN _idinteres           INT,
    IN _idmoneda            INT,
    IN _monto               NUMERIC(10,3),
    IN _plazo               INT,
    IN _intereses           NUMERIC(10,3),
    IN _fecha_registro      DATE )
BEGIN
    -- Calcular las fechas antes de la actualización
    DECLARE _fecha_inicio DATE;
    DECLARE _fecha_fin DATE;
    
    SET _fecha_inicio = DATE_ADD(_fecha_registro, INTERVAL 1 MONTH);
    SET _fecha_fin = DATE_ADD(_fecha_registro, INTERVAL _plazo MONTH);
    
    -- Actualizar la tabla
    UPDATE tblprestamos
    SET idclienteFK = _idcliente,
        idtipoprestamoFK = _idtipoprestamo,
        idinteresFK = _idinteres,
        idmonedaFK = _idmoneda,
        monto = _monto,
        plazo = _plazo,
        intereses = _intereses,
        fecha_registro = _fecha_registro,
        fecha_inicio = _fecha_inicio,
        fecha_fin = _fecha_fin
      WHERE idprestamo = _idprestamo;
END //
DELIMITER ;




ALTER TABLE tblprestamos
MODIFY COLUMN fecha_registro DATE;

ALTER TABLE tblprestamos
MODIFY COLUMN  fecha_fin DATE GENERATED ALWAYS AS (DATE_ADD(fecha_registro, INTERVAL plazo MONTH)); 

DELIMITER //
CREATE PROCEDURE Filtrar_Detalle_Prestamos(f_inicio DATE, f_fin DATE)
BEGIN
    SELECT 
        P.codigo AS codigo_prestamo,
        CONCAT(CL.nombre, ' ', CL.apellido)AS nombre,
        DATE_FORMAT(P.fecha_registro, '%Y-%m-%d') AS fecha_desembolso,
        DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
        DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') AS fecha_fin,
        IF(M.simbolo = 'C$', CONCAT(M.simbolo, '', P.monto), '-') AS monto_cordoba,
        IF(M.simbolo = '$', CONCAT(M.simbolo, '', P.monto), '-') AS monto_dolar,
        IF(P.plazo = 1, CONCAT(P.plazo,' mes'), CONCAT(P.plazo,' meses')) AS plazo,
        CONCAT(ROUND(I.descripcion, 1), '%') AS taza_intereses,
        IF(M.simbolo = 'C$', CONCAT(M.simbolo, '', P.intereses), '-') AS intereses_cordoba,
        IF(M.simbolo = '$', CONCAT(M.simbolo,'', P.intereses), '-') AS intereses_dolar,
        IF(M.simbolo = 'C$', CONCAT(M.simbolo, '', P.intereses + P.monto), '-') AS total_cordoba,
        IF(M.simbolo = '$', CONCAT(M.simbolo, '', P.intereses + P.monto), '-') AS total_dolar
    FROM tblprestamos AS P 
    INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
    INNER JOIN tblclientes AS CL ON P.idclienteFK = CL.idcliente
    INNER JOIN tblintereses AS I ON P.idinteresFK = I.idinteres
    WHERE P.fecha_registro BETWEEN f_inicio AND f_fin
    GROUP BY P.idprestamo
    ORDER BY  fecha_desembolso;
END //

-- Funciones
-- 1.
DELIMITER //
CREATE FUNCTION validar_monto_exacto_pagar(_idprestamo INT, _ingreso NUMERIC(10, 3))
RETURNS BOOLEAN 
BEGIN 
    DECLARE total_pagado_x_prestamo NUMERIC(10, 3);
    DECLARE total_abonos_x_prestamo NUMERIC(10, 3);

    SELECT 
        IFNULL(SUM(PO1.pago), 0) INTO total_pagado_x_prestamo
    FROM tblprestamos AS P1 
    INNER JOIN tblcuotas AS C1 ON P1.idprestamo = C1.idprestamoFK	
    INNER JOIN tblpagos AS PO1 ON C1.idcuota = PO1.idcuotaFK
    WHERE idprestamo = _idprestamo;

    SELECT
        SUM(C2.abono) INTO total_abonos_x_prestamo
    FROM tblprestamos AS P2
    INNER JOIN tblcuotas AS C2 ON P2.idprestamo = C2.idprestamoFK
    WHERE idprestamo = _idprestamo;

    IF ROUND((_ingreso + total_pagado_x_prestamo), 3) > total_abonos_x_prestamo THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //
DELIMITER ;

-- 2.
DELIMITER //
CREATE FUNCTION cliente_pretamos_pend( _idcliente INT)
RETURNS BOOLEAN
BEGIN
    DECLARE conteo_prest_pend INT;

    SELECT 
        COUNT(*) INTO conteo_prest_pend
    FROM tblprestamos AS P INNER JOIN tblclientes AS C
    ON P.idclienteFK = C.idcliente
    WHERE C.idcliente = _idcliente AND P.estado = 1;

    IF conteo_prest_pend > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
//
DELIMITER ;


-- TRIGGER
DELIMITER //
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
END;
//
DELIMITER ;

-- DROP TRIGGER IF EXISTS act_estado_prestamo;
