const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const pool = require('../config/database');
const {isNotLoggedIn, isLoggedIn, isLoggedInAdmin, isLoggedInClient} = require('../lib/auth');
const passwordValidation = require('../lib/passwordValidation');
const e = require('connect-flash');
const { jsPDF } = require('jspdf');
const Excel = require('exceljs');
const bodyParser = require('body-parser');

router.get('/', isLoggedIn, async(req, res) => {
    await pool.query(`
    SELECT DISTINCT 
        IF(MONTH(P.fecha_registro) = 12, YEAR(DATE_SUB(C.fecha_pago, INTERVAL 1 MONTH)), YEAR(C.fecha_pago)) AS fecha
    FROM tblprestamos AS P
    INNER JOIN tblcuotas AS C ON P.idprestamo = C.idprestamoFK
    ORDER BY fecha ASC;
`, (error, resultado) => {
        if(error){
            console.log(error);
        }
        res.render('admin/start', {resultado});
    });
});

//Clientes
router.get('/client'/*, isLoggedIn*/, async(req, res) => {
    try {
        const ciudades = await pool.query(`SELECT * FROM tblciudad`);
        const clientes = await pool.query(`
            SELECT   idcliente, 
                CONCAT(nombre, ' ', apellido) AS nombre 
            FROM tblclientes
            WHERE estado = 1`);
        res.render('admin/client', {ciudades, clientes});
    } catch (error) {
        console.log(error);
    }
});

router.get("/table_client/:estado", /*isLoggedIn,*/ async(req, res) => {
    await pool.query(`
        SELECT 
            idcliente,
            CONCAT(nombre, ' ', apellido) AS nombre_completo,
            direccion,
            celular, 
            estado
        FROM tblclientes
        WHERE estado = ?`,[req.params.estado], (error, resultado) => {
    if (error) {
        console.log(error);
    } else {
        res.json(resultado);
    }});
});

router.post("/client", /*isLoggedIn,*/ async(req, res) => {
    const nombre = req.body.nombre;
    const apellido = req.body.apellido;
    const cedula = req.body.cedula;
    const celular = req.body.celular;
    const direccion = req.body.direccion;
    const fecha_nacimiento = req.body.fecha_nacimiento;
    const estado_civil = req.body.estado_civil;
    const idciudadFK = req.body.idciudadFK;
    const sexo = req.body.sexo.charAt(0);
    const usuario = req.body.usuario;
    const contrasena = await passwordValidation.encryptPassword(req.body.contrasena);

    await pool.query(`
        CALL pa_insertar_clientes (?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?)`, [   
        nombre, apellido, 
        fecha_nacimiento,
        sexo, cedula,
        celular, direccion,
        usuario, contrasena,
        estado_civil, idciudadFK ], function(error, resultado) {
    if (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al guardar los datos' });
    } else {
        res.json({ mensaje: 'Datos guardados correctamente' });
    }
    });
});

router.get('/edit_client/:id', async(req, res) => {
    await pool.query(`
        SELECT 
            CL.idcliente AS idcliente,
            CL.nombre AS nombre,
            CL.apellido AS apellido,
            CL.cedula AS cedula,
            CL.celular AS celular,
            CL.direccion AS direccion,
            DATE_FORMAT(CL.fecha_nacimiento, '%Y-%m-%d') AS fecha_nacimiento,
            CL.estado_civil,
            CL.usuario AS usuario,
            C.idciudad AS idciudad,
            CL.sexo AS sexo
        FROM tblclientes CL INNER JOIN tblciudad AS C
        ON CL.idciudadFK = C.idciudad
        WHERE idcliente = ?`, [req.params.id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos ' + error});
        } else {
            res.json(resultado[0]);
        }
    });
});

router.get('/edit_client_ciudad', async(req, res) => {
    await pool.query(`
        SELECT 
            idciudad,
            nombre
        FROM tblciudad`, (error, resultado) => {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos '+ error });
        } else {
            res.json(resultado);
        }
    });
});

router.post('/update_client', async(req, res) => {
    const idcliente = req.body.act_idcliente;
    const nombre = req.body.act_nombre;
    const apellido = req.body.act_apellido;
    const cedula = req.body.act_cedula;
    const celular = req.body.act_celular;
    const direccion = req.body.act_direccion;
    const fecha_nacimiento = req.body.act_fecha_nacimiento;
    const estado_civil = req.body.act_estado_civil;
    const usuario = req.body.act_usuario;
    const sexo = req.body.act_sexo.charAt(0);
    const idciudad = req.body.act_idciudadFK;
    
    await pool.query(`CALL pa_actualizar_cliente (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [idcliente,
        nombre, 
        apellido,
        fecha_nacimiento,
        sexo,
        cedula, 
        celular, 
        direccion, 
        usuario, 
        estado_civil,
        idciudad, 
        ], (error, resultado) => {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos '});
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.post('/update_client_state/:id',/* isLoggedIn,*/ async(req, res) => {
    await pool.query('CALL pa_actualizar_cliente_estado(?)', [req.params.id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.get('/get_client', async(req, res) => {
    await pool.query(`
        SELECT   idcliente, 
            CONCAT(nombre, ' ', apellido) AS nombre 
        FROM tblclientes
        WHERE estado = 1`, (error, resultado) => {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos '+ error });
        } else {
            res.json(resultado);
        }
    });
});

router.post("/client_detail", async(req, res) => {
    const idcliente = req.body.idcliente;
    const ocupacion = req.body.ocupacion;
    const trabajo = req.body.trabajo;
    const fecha_inicio = req.body.fecha_inicio;
    const fecha_fin = req.body.fecha_fin;
    const salario = req.body.salario;
    const telefono_trabajo = req.body.telefono_trabajo;

    await pool.query(`INSERT INTO tbldetalle_cliente( trabajo,
                                                ocupacion,
                                                salario,
                                                telefono_trabajo,
                                                fecha_inicio,
                                                fecha_fin,
                                                idclienteFK) 
                                VALUES (?, ? ,? ,?, ?, ?, ?)`, 
                                                [trabajo, 
                                                ocupacion,
                                                salario,
                                                telefono_trabajo,
                                                fecha_inicio,
                                                fecha_fin,
                                                idcliente], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get('/edit_client_detail/:id', async(req, res) => {
    await pool.query(`SELECT 
                        DC.iddetallecliente AS iddetallecliente,
                        C.idcliente AS idcliente,
                        CONCAT(C.nombre,' ', C.apellido) AS nombre,
                        DC.ocupacion, 
                        DC.trabajo,
                        DC.salario,
                        DC.telefono_trabajo,
                        DATE_FORMAT(DC.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
                        DATE_FORMAT(DC.fecha_fin, '%Y-%m-%d') AS fecha_fin
                    FROM tbldetalle_cliente AS DC INNER JOIN tblclientes AS C
                    ON DC.idclienteFK = C.idcliente
                    WHERE C.idcliente = ?
                    ORDER BY DC.iddetallecliente DESC
                    LIMIT 1`, [req.params.id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            if(resultado[0] === undefined){
                res.json({ mensaje: 'Cliente sin detalle cliente'});
            }else{
                res.json(resultado[0]);
            }  
        }
    });
});

router.get('/edit_client_detail_nombre', async(req, res) => {
    await pool.query(`SELECT 
                        idcliente,
                        CONCAT(nombre,' ',apellido) AS nombre
                    FROM tblclientes`, function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado);
        }
    });
});

router.post('/update_client_detail', async(req, res) => {
    const idcliente = req.body.act_idcliente;
    const ocupacion = req.body.act_ocupacion;
    const trabajo = req.body.act_trabajo;
    const salario = req.body.act_salario;
    const telefono_trabajo = req.body.act_telefono_trabajo;
    const fecha_inicio = req.body.act_fecha_inicio;
    const fecha_fin = req.body.act_fecha_fin;
    const iddetallecliente = req.body.act_iddetallecliente;
    await pool.query(`UPDATE tbldetalle_cliente
                             SET ocupacion = ?,
                                 trabajo = ?,
                                 salario = ?,
                                 telefono_trabajo = ?,
                                 fecha_inicio = ?,
                                 fecha_fin = ?,
                                 idclienteFK = ?
                            WHERE iddetallecliente = ?`, [ocupacion, trabajo, salario, telefono_trabajo, fecha_inicio, fecha_fin, idcliente, iddetallecliente], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//type
router.get('/type', async(req, res) => {
    res.render('admin/type');
});

router.post("/type", async(req, res) => {
    const descripcion = req.body.descripcion;
    await pool.query('INSERT INTO tbltipoprestamos (descripcion) VALUES (?)', [descripcion], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get("/table_type/:estado", async(req, res) => {
    const estado = req.params.estado;
    console.log(estado)
    await pool.query(`SELECT * FROM tbltipoprestamos WHERE estado = ?`, [estado], function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.get('/edit_type/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tbltipoprestamos WHERE idtipoprestamo = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_type', async(req, res) => {
    const id = req.body.act_idtipoprestamo;
    const descripcion = req.body.act_descripcion;
    await pool.query('UPDATE tbltipoprestamos SET descripcion = ? WHERE idtipoprestamo = ?', [descripcion, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.post('/update_loan_type_state/:id', async(req, res) => {
    await pool.query('CALL pa_actualizar_tipoprestamo_estado (?)', [req.params.id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//Users
router.get('/users', async(req, res) => {
    let operacion = 'Ingresar nuevo Usuario';
    res.render('admin/users', {operacion});
});

router.post("/users",/* isLoggedIn,*/ async(req, res) => {
    const usuario = req.body.usuario;
    const contrasena = await passwordValidation.encryptPassword(req.body.contrasena);

    await pool.query('INSERT INTO tblusuarios (usuario, contrasena) VALUES (?, ?)', [usuario, contrasena], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get("/table_users/:estado",/* isLoggedIn,*/ async(req, res) => {
    const estado = req.params.estado;
    await pool.query(`SELECT * FROM tblusuarios WHERE estado = ?`, [estado], function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.get('/edit_users/:id', /*isLoggedIn,*/ async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblusuarios WHERE idusuario = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_users', /*isLoggedIn,*/ async(req, res) => {
    const id = req.body.act_idusuario;
    const usuario = req.body.act_usuario;
    await pool.query('UPDATE tblusuarios SET usuario = ? WHERE idusuario = ?', [usuario, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.post('/update_users_state/:id',/* isLoggedIn,*/ async(req, res) => {
    await pool.query('CALL pa_actualizar_usuario_estado(?)', [req.params.id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//Moneda
router.get('/currency', async(req, res) => {
    res.render('admin/currency');
});

router.get("/table_currency", async(req, res) => {
    await pool.query(`SELECT * FROM tblmoneda`, function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.post("/currency", async(req, res) => {
    const simbolo = req.body.simbolo;
    const descripcion = req.body.descripcion;
    await pool.query('INSERT INTO tblmoneda (descripcion, simbolo) VALUES (?, ?)', [descripcion, simbolo], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get('/edit_currency/:id', /*isLoggedIn,*/ async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblmoneda WHERE idmoneda = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_currency', async(req, res) => {
    const id = req.body.act_idmoneda;
    const descripcion = req.body.act_descripcion;
    const simbolo = req.body.act_simbolo;
    await pool.query('UPDATE tblmoneda SET descripcion = ?, simbolo = ? WHERE idmoneda = ?', [descripcion, simbolo,  id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.delete('/delete_currency/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblmoneda WHERE idmoneda = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

//Forma de pago
router.get('/payshape', async(req, res) => {
    res.render('admin/payshape');
});

router.get("/table_payshape", async(req, res) => {
    await pool.query(`SELECT * FROM tblformapago`, function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.post("/payshape", async(req, res) => {
    const nombre = req.body.nombre;
    await pool.query('INSERT INTO tblformapago (descripcion) VALUES (?)', [nombre], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get('/edit_payshape/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblformapago WHERE idformapago = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_payshape', async(req, res) => {
    const id = req.body.act_idformapago;
    const nombre = req.body.act_nombre;
    await pool.query('UPDATE tblformapago SET descripcion = ? WHERE idformapago = ?', [nombre, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.delete('/delete_payshape/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblformapago WHERE idformapago = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

//Interes
router.get('/interest', async(req, res) => {
    res.render('admin/interest');
});

router.get("/table_interest", async(req, res) => {
    await pool.query(`SELECT * FROM tblintereses`, function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.post("/interest", async(req, res) => {
    const descripcion = req.body.descripcion;
    await pool.query('INSERT INTO tblintereses (descripcion) VALUES (?)', [descripcion], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get('/edit_interest/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblintereses WHERE idinteres = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_interest', async(req, res) => {
    const id = req.body.act_idinteres;
    const descripcion = req.body.act_descripcion;
    await pool.query('UPDATE tblintereses SET descripcion = ? WHERE idinteres = ?', [descripcion, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.delete('/delete_interest/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblintereses WHERE idinteres = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

//Roles de Usuarios
router.get('/role', async(req, res) => {
    res.render('admin/role');
});

router.get("/table_role", async(req, res) => {
    await pool.query(`SELECT * FROM tblroles`, function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.post("/role", async(req, res) => {
    const descripcion = req.body.descripcion;
    await pool.query('INSERT INTO tblroles (descripcion) VALUES (?)', [descripcion], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get('/edit_role/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblroles WHERE idrol = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_role', async(req, res) => {
    const id = req.body.act_idrol;
    const descripcion = req.body.act_descripcion;
    await pool.query('UPDATE tblroles SET descripcion = ? WHERE idrol = ?', [descripcion, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.delete('/delete_role/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblroles WHERE idrol = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

// Paises
router.get("/countries", async(req, res) => {
    res.render('admin/countries');
});

router.post("/countries", async(req, res) => {
    const pais = req.body.pais;
    await pool.query('INSERT INTO tblpais (nombre) VALUES (?)', [pais], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.get("/table_countries", async(req, res) => {
    await pool.query('SELECT * FROM tblpais', function(error, resultado) {
        if (error) {
           console.log(error);
        } else {
            res.json(resultado); 
        }
    });
})

router.delete('/delete_countries/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblpais WHERE idpais = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

router.get('/edit_countries/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('SELECT * FROM tblpais WHERE idpais = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.post('/update_countries', async(req, res) => {
    const id = req.body.id;
    const pais = req.body.pais;
    await pool.query('UPDATE tblpais SET nombre = ? WHERE idpais = ?', [pais, id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//Departamentos
router.get("/department", async(req, res) => {
    await pool.query('SELECT * FROM tblpais ', function(error, resultado) {
        if (error) {
            console.log(error);
        }
        res.render('admin/department', {resultado});
    });
});

router.get("/table_department", async(req, res) => {
    await pool.query(`SELECT 
                        D.nombre AS nombre, 
                        P.nombre AS pais,
                        iddepartamento
                    FROM tbldepartamento AS D 
                    INNER JOIN tblpais AS P 
                    ON D.idpaisFK = P.idpais`, function(error, resultado) {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado); 
        }
    });
});

router.get("/table_department/:id", async(req, res) => {
    const id = req.params.id;
    await pool.query(`SELECT 
                        iddepartamento,
                        D.nombre AS nombre,
                        P.nombre AS pais
                        FROM tbldepartamento AS D 
                    INNER JOIN tblpais AS P
                    ON D.idpaisFK = P.idpais WHERE P.idpais = ?`, [id],(error, resultado) => {
        if (error) {
            console.log(error);
            
        } else {
            res.json(resultado);
        }
    });
});

router.post("/department", async(req, res) => {
    const pais = req.body.pais;
    const departamento = req.body.departamento;
    await pool.query('INSERT INTO tbldepartamento (nombre, idpaisFK) VALUES (?, ?)', [departamento, pais], function(error, resultados) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.delete('/delete_department/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tbldepartamento WHERE iddepartamento = ?', [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

router.get('/edit_department/:id', async (req, res) => {
    const id = req.params.id;
    await pool.query(`SELECT 
                        iddepartamento,
                        D.nombre AS nombre, 
                        P.nombre AS pais,
                        idpais
                    FROM tbldepartamento AS D 
                    INNER JOIN tblpais AS P 
                    ON D.idpaisFK = P.idpais 
                    WHERE iddepartamento = ?`, [id], function(error, resultado) {
        if (error){
            console.log(error);
        }
        else{
            res.json(resultado[0]);
        }
    });
});

router.get('/edit_department_paises', async(req, res) => {
    await pool.query('SELECT * FROM tblpais', (error, resultado) => {
        if (error){
            console.log(error);
        }
        else{
            res.json(resultado);
        }
    });
});

router.post('/update_department', async(req, res) => {
    const departamento = req.body.act_departamento;
    const idpais = req.body.act_pais;
    const iddepartamento = req.body.act_iddepartamento;

    console.log(req.body);
    await pool.query('UPDATE tbldepartamento SET nombre = ?, idpaisFK = ? WHERE iddepartamento = ?', [departamento, idpais, iddepartamento], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//Ciudad
router.get("/city", async(req, res) => {
    await pool.query(`SELECT * FROM tbldepartamento`, function(error, resultado) {
        if (error) {
            console.log(error);
        }
        res.render('admin/city', {departamentos:resultado});
    });
});

router.get('/get_country/:id', async(req, res) => {
    const id =  req.params.id;
    await pool.query(`SELECT 
                        P.nombre AS pais 
                    FROM tbldepartamento AS D
                    INNER JOIN tblpais AS P 
                    ON D.idpaisFK = P.idpais WHERE D.iddepartamento = ?`, [id], (error, resultado) => {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado[0]);
        }
    });
});

router.get("/table_city", async(req, res) => {
    await pool.query(`SELECT 
                        C.nombre AS ciudad, 
                        P.nombre AS pais,
                        C.idciudad AS idciudad
                    FROM tblciudad AS C 
                    INNER JOIN tbldepartamento AS D
                    ON C.iddepartamentoFK = D.iddepartamento 
                    INNER JOIN tblpais AS P 
                    ON D.idpaisFK = P.idpais`,(error, resultado) => {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.get("/table_city/:id", async(req, res) => {
    const id = req.params.id;
    await pool.query(`SELECT 
                        C.nombre AS ciudad, 
                        P.nombre AS pais,
                        C.idciudad AS idciudad
                    FROM tblciudad AS C 
                    INNER JOIN tbldepartamento AS D
                    ON C.iddepartamentoFK = D.iddepartamento 
                    INNER JOIN tblpais AS P 
                    ON D.idpaisFK = P.idpais 
                    WHERE D.iddepartamento = ?`, [id],(error, resultado) => {
        if (error) {
            console.log(error);
        } else {
            res.json(resultado);
        }
    });
});

router.post("/city", async(req, res) => {
    const ciudad = req.body.ciudad;
    const iddepartamento = req.body.departamento;
    await pool.query('INSERT INTO tblciudad (nombre, iddepartamentoFK) VALUES (?, ?)', [ciudad, iddepartamento], function(error, resultados) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al guardar los datos' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
    });
});

router.delete('/delete_city/:id', async(req, res) => {
    const id = req.params.id;
    await pool.query('DELETE FROM tblciudad WHERE idciudad = ?', [id], function(error, resultados) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al eliminar los datos' });
        } else {
            res.json({ mensaje: 'Datos eliminados correctamente' });
        }
    });
});

router.get('/edit_city/:id', async (req, res) => {
    const id = req.params.id;
    await pool.query(`SELECT 
                        idciudad,
                        C.nombre AS ciudad, 
                        iddepartamento
                    FROM tblciudad AS C 
                    INNER JOIN tbldepartamento AS D 
                    ON C.iddepartamentoFK = D.iddepartamento
                    WHERE idciudad = ?`, [id], function(error, resultado) {
        if (error){
            console.log(error);
        }
        else{
            res.json(resultado[0]);
        }
    });
});

router.get('/edit_city_departamentos', async(req, res) => {
    await pool.query('SELECT * FROM tbldepartamento', (error, resultado) => {
        if (error){
            console.log(error);
        }
        else{
            res.json(resultado);
        }
    });
});

router.post('/update_city', async(req, res) => {
    const iddepartamento = req.body.act_departamento;
    const ciudad = req.body.act_ciudad;
    const idciudad = req.body.act_idciudad;

    console.log(req.body);
    await pool.query('UPDATE tblciudad SET nombre = ?, iddepartamentoFK = ? WHERE idciudad = ?', [ciudad, iddepartamento, idciudad], (error, resultado) => {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

//Prestamo
router.get('/loan', async(req, res) => {
    try {
        const clientes = await pool.query(`SELECT * FROM tblclientes WHERE estado = 1`);
        const intereses = await pool.query('SELECT * FROM tblintereses');
        const tipoprestamo = await pool.query('SELECT * FROM tbltipoprestamos WHERE estado = 1');
        const formapago = await pool.query('SELECT * FROM tblformapago');
        const moneda = await pool.query('SELECT * FROM tblmoneda');

        res.render('admin/loan', {clientes, tipoprestamo, intereses, formapago, moneda});
    } catch (error) {
        console.log(error)
        res.status(500).json({ mensaje: 'Error al mostrar los datos' });
    }
});

router.post('/loan', async(req, res) => {
    try {
        const plazo = parseInt(req.body.plazo);
        const monto = parseFloat(req.body.monto);
        const fecha_desembolso = req.body.fecha_registro;
        let codigo = await pool.query('SELECT IFNULL(MAX(idprestamo), 0) + 1 AS max_id FROM tblprestamos;');
        const valor_interes = await pool.query('SELECT ROUND(descripcion / 100, 3) AS valor_interes FROM tblintereses WHERE idinteres = ?', [req.body.interes]);
        codigo = codigo[0].max_id.toString().padStart(4, '0');
        let intereses = monto;
        let sumainterescorriente = 0;
        for(let i=0; i <  parseInt(plazo); i++){
            sumainterescorriente += (intereses * valor_interes[0].valor_interes);
            intereses -= parseFloat(monto/plazo);
        }
        const insertar_prestamo =   await pool.query(`CALL pa_insertar_prestamos (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [
            codigo, 
            req.body.tipoprestamo, 
            req.body.cliente, 
            req.session.userId, 
            req.body.interes, 
            req.body.formapago, 
            monto, 
            plazo,
            sumainterescorriente,
            req.body.moneda,
            fecha_desembolso ]);
        const fecha_registro =  await pool.query (`SELECT fecha_registro FROM tblprestamos WHERE idprestamo = ?`, [insertar_prestamo[0][0].obt_id]);
        intereses = monto;
        for(let i=0; i <  parseInt(plazo); i++){
            await pool.query (`
            CALL pa_insertar_cuotas (?, ?, ?, ?, ?, ?)`, [ 
            insertar_prestamo[0][0].obt_id, 
            i+1, 
            new Date(fecha_registro[0].fecha_registro.setMonth(fecha_registro[0].fecha_registro.getMonth() + 1)), 
            parseFloat(monto)/parseInt(plazo),
            intereses * valor_interes[0].valor_interes,
            (parseFloat(monto) + parseFloat(sumainterescorriente)) / parseInt(plazo) ]);
            intereses -= parseFloat(monto)/parseInt(plazo);
        }
        res.json({ mensaje: 'Datos guardados correctamente' });
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al guardar los datos' });
    }
});

router.get("/table_loan", async(req, res) => {
    try {
        const resultado = await pool.query(`
            SELECT
                P.idprestamo AS idprestamo,
                P.codigo AS codigo, 
                T.descripcion AS tipoprestamo,
                CONCAT(C.nombre,' ',C.apellido) AS cliente,
                CONCAT(simbolo, P.monto) AS monto,
                DATE_FORMAT(P.fecha_registro, '%Y-%m-%d') AS fecha_registro_formateada,
                DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
                DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') fecha_fin,
                plazo,
                CONCAT(M.simbolo, P.intereses) AS intereses,
                CONCAT(M.simbolo, '', SUM(CO.abono) -  (SELECT 
                                    IFNULL(SUM(PO.pago), 0) AS pago
                                FROM tblcuotas AS C
                                INNER JOIN tblprestamos AS PP ON C.idprestamoFK = PP.idprestamo
                                INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                                    WHERE idprestamo = P.idprestamo)) AS abono_restante
            FROM tblprestamos AS P 
            INNER JOIN tblclientes AS C ON P.idclienteFK = C.idcliente
            INNER JOIN tbltipoprestamos AS T ON P.idtipoprestamoFK = T.idtipoprestamo
            INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
            INNER JOIN tblcuotas AS CO ON P.idprestamo = CO.idprestamoFK
            GROUP BY P.idprestamo
            ORDER BY P.idprestamo ASC;`);
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.get("/table_loan/:estado", async(req, res) => {
    try {
        const resultado = await pool.query(`
        SELECT
            P.idprestamo AS idprestamo,
            P.codigo AS codigo, 
            T.descripcion AS tipoprestamo,
            CONCAT(C.nombre,' ',C.apellido) AS cliente,
            CONCAT(simbolo, P.monto) AS monto,
            DATE_FORMAT(P.fecha_registro, '%Y-%m-%d') AS fecha_registro_formateada,
            DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
            DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') fecha_fin,
            plazo,
            CONCAT(M.simbolo, P.intereses) AS intereses,
            CONCAT(M.simbolo, '', SUM(CO.abono) -  (SELECT 
                                IFNULL(SUM(PO.pago), 0) AS pago
                            FROM tblcuotas AS C
                            INNER JOIN tblprestamos AS PP ON C.idprestamoFK = PP.idprestamo
                            INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                                WHERE idprestamo = P.idprestamo)) AS abono_restante
        FROM tblprestamos AS P 
        INNER JOIN tblclientes AS C ON P.idclienteFK = C.idcliente
        INNER JOIN tbltipoprestamos AS T ON P.idtipoprestamoFK = T.idtipoprestamo
        INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
        INNER JOIN tblcuotas AS CO ON P.idprestamo = CO.idprestamoFK
        WHERE P.estado = ?
        GROUP BY P.idprestamo
        ORDER BY P.idprestamo ASC;`, [req.params.estado]);
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.get("/get_quota/:id", async(req, res) => {
    try {
        const resultado =   await pool.query(`
            SELECT 
                cuota, 
                C.idcuota AS idcuota, 
                DATE_FORMAT(fecha_pago, '%Y-%m-%d') AS fecha_pago,
                CONCAT(M.simbolo, C.capital) AS capital,
                CONCAT(M.simbolo, C.interescorriente) AS interescorriente,
                CONCAT(M.simbolo, C.abono) AS abono,
                CASE C.estado
                    WHEN 0 THEN 'Mora'  
                    WHEN 1 THEN 'Pendiente'
                    WHEN 2 THEN 'Cancelado'  
                    WHEN 3 THEN 'Parcial'  
                    ELSE 'Incorrecto'  
                END as estado
            FROM tblcuotas AS C INNER JOIN tblprestamos AS P
            ON C.idprestamoFK = P.idprestamo
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            WHERE idprestamo = ?`, [req.params.id]);
        const detalle_resultado  =  await pool.query (`
        SELECT   
            P.idprestamo AS idprestamo, 
            P.codigo AS codigo,
            CONCAT(M.simbolo, SUM(C.capital)) AS capital, 
            CONCAT(M.simbolo, SUM(C.interescorriente)) AS interescorriente,
            CONCAT(M.simbolo, SUM(C.abono)) AS abono,
            CONCAT(CL.nombre, ' ', CL.apellido) AS cliente,
            DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
            DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') AS fecha_fin,
            CONCAT(M.simbolo, P.monto) AS monto,
            P.plazo AS plazo,
            CONCAT(I.descripcion,'%     ', SUBSTRING(I.descripcion/100, 1, 5)) AS interes,
            CONCAT(M.simbolo, ' ', SUM(C.abono) -  (SELECT 
                                                        IFNULL(SUM(PO.pago), 0) AS pago
                                                    FROM tblcuotas AS C
                                                    INNER JOIN tblprestamos AS PP ON C.idprestamoFK = PP.idprestamo
                                                    INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                                                    WHERE idprestamo = P.idprestamo)) AS saldo_pendiente,
            CONCAT(M.simbolo, ' ',  (SELECT 
                                        IFNULL(SUM(D.descuento), 0) AS descuento
                                    FROM tblprestamos AS PP
                                    INNER JOIN tbldescuento AS D
                                    ON PP.idprestamo = D.idprestamoFK
                                    WHERE idprestamo = P.idprestamo)) AS descuento
        FROM tblprestamos AS P INNER JOIN tblcuotas AS C
        ON C.idprestamoFK = P.idprestamo
        INNER JOIN tblclientes AS CL
        ON P.idclienteFK = CL.idcliente
        INNER JOIN tblintereses AS I
        ON P.idinteresFK = I.idinteres
        INNER JOIN tblmoneda AS M
        ON P.idmonedaFK = M.idmoneda
        WHERE idprestamo = ?`,  [req.params.id]);
        res.json({resultado, detalle_resultado});
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al guardar los datos' });
    }
});

router.get('/sum_payment/:id', async(req, res) => {
    const id = req.params.id;
    try {
        let obtener_pago = await pool.query(`
            SELECT 
                CONCAT(M.simbolo,' ', PO.pago) AS pago,
                DATE_FORMAT(PO.fecha_pago, '%Y-%m-%d %h:%i %p') AS fecha_pago
            FROM tblprestamos AS P INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            INNER JOIN tblcuotas AS C 
            ON P.idprestamo = C.idprestamoFK
            INNER JOIN tblpagos AS PO 
            ON C.idcuota = PO.idcuotaFK
            WHERE C.idcuota = ?`, [id]);

        let total  =  await pool.query (`
            SELECT 
                CONCAT(M.simbolo,' ', SUM(PO.pago)) AS pago,
                CONCAT(M.simbolo,' ', C.abono - SUM(PO.pago)) AS pendiente,
                CASE C.estado
                    WHEN 0 THEN 'Mora'  
                    WHEN 1 THEN 'Pendiente'
                    WHEN 2 THEN 'Cancelado'  
                    WHEN 3 THEN 'Parcial'  
                    ELSE 'Incorrecto'  
                END as estado
            FROM tblprestamos AS P INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            INNER JOIN tblcuotas AS C 
            ON P.idprestamo = C.idprestamoFK
            INNER JOIN tblpagos AS PO 
            ON C.idcuota = PO.idcuotaFK
            WHERE C.idcuota = ?`,  [id]);
        res.json({obtener_pago, total});
    } catch (error) {
        console.log(error);
    }
});

//Pagos
router.get('/payments', async(req, res) => {
    try {
        const codigos = await pool.query("SELECT idprestamo, codigo FROM tblprestamos");
        const clientes = await pool.query(` 
            SELECT 
                DISTINCT 
                C.idcliente AS idcliente,
                CONCAT(C.nombre,' ',C.apellido) AS nombre
            FROM tblprestamos AS P 
            INNER JOIN tblclientes AS C
            ON P.idclienteFK = C.idcliente
            WHERE P.estado = 1`)
        res.render('admin/payments',{clientes});
    } catch (error) {
        console.log(error);
    }
});

router.get("/table_loan_cliente/:id", async(req, res) => {
    try {
        const resultado = await pool.query(`
        SELECT
            P.idprestamo AS idprestamo,
            P.codigo AS codigo, 
            CONCAT(C.nombre, ' ', C.apellido) AS cliente,
            CONCAT(simbolo, P.monto) AS monto,
            CONCAT(M.simbolo, P.intereses) AS intereses,
            CONCAT(M.simbolo, SUM(CU.abono)) AS total,
            CONCAT(M.simbolo, '', SUM(CU.abono) -  (SELECT 
                                IFNULL(SUM(PO.pago), 0) AS pago
                            FROM tblcuotas AS C
                            INNER JOIN tblprestamos AS PP ON C.idprestamoFK = PP.idprestamo
                            INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                            WHERE idprestamo = P.idprestamo)) AS abono_restante
        FROM tblprestamos AS P 
        INNER JOIN tblclientes AS C
        ON P.idclienteFK = C.idcliente
        INNER JOIN tblmoneda AS M
        ON P.idmonedaFK = M.idmoneda
        INNER JOIN tblcuotas AS CU
        ON P.idprestamo = CU.idprestamoFK
        WHERE C.idcliente = ? AND P.estado = 1
        GROUP BY P.idprestamo`, [req.params.id]);
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.post("/get_payments_quotas", async(req, res) => {
    try {
        const abono = await pool.query(`  
        SELECT
            IF((SELECT 
                    C2.abono - SUM(PO2.pago) AS abono
                FROM tblprestamos AS P2
                INNER JOIN tblcuotas AS C2
                ON P2.idprestamo = C2.idprestamoFK
                INNER JOIN tblpagos AS PO2
                ON PO2.idcuotaFK = C2.idcuota
                WHERE idcuota = (SELECT 
                                    MAX(C3.idcuota) AS ultima_cuota
                                FROM tblprestamos AS P3
                                INNER JOIN tblcuotas AS C3
                                ON P3.idprestamo = C3.idprestamoFK
                                WHERE idprestamo = P1.idprestamo)) IS NULL
            ,   (SELECT 
                    C4.abono AS abono
                FROM tblprestamos AS P4
                INNER JOIN tblcuotas AS C4
                ON P4.idprestamo = C4.idprestamoFK
                WHERE idprestamo = P1.idprestamo
                LIMIT 1)
            ,   (SELECT 
                    C5.abono - IFNULL(SUM(PO5.pago), 0) AS abono
                FROM tblprestamos AS P5
                INNER JOIN tblcuotas AS C5
                ON P5.idprestamo = C5.idprestamoFK
                INNER JOIN tblpagos AS PO5
                ON PO5.idcuotaFK = C5.idcuota
                WHERE C5.idcuota = (SELECT 
                                        MAX(C6.idcuota) AS ultima_cuota
                                    FROM tblprestamos AS P6
                                    INNER JOIN tblcuotas AS C6
                                    ON P6.idprestamo = C6.idprestamoFK
                                    WHERE idprestamo = P1.idprestamo)))  AS dinero_pago
        FROM tblprestamos AS P1
        WHERE idprestamo = ?`, [req.body.det_idprestamo]);
        res.json(abono);
    } catch (error) {
        console.log(error);
    }
});

router.post("/payments_quotas", async (req, res) => {
    try {
        let pago = parseFloat(parseFloat(req.body.det_pago).toFixed(3));
        let total_descuento = parseFloat(req.body.det_saldo_descuento.split(" ")[1]);
        let descuento_x_pago = parseFloat(parseFloat(req.body.det_descuento || 0).toFixed(3));
        const idprestamo = req.body.det_idprestamo;
        pago += descuento_x_pago;
        const resultado = await pool.query(`SELECT validar_monto_exacto_pagar(?, ?) AS validar_monto_exacto_pagar`, [idprestamo, pago]);
        if (resultado[0].validar_monto_exacto_pagar === 1) {
            res.json({ mensaje: 'La cantidad ingresada es mayor a lo que debes en el prestamo' });
        } else {
            if (descuento_x_pago != 0) {
                await pool.query('INSERT INTO tbldescuento (descuento, idprestamoFK) VALUES (?, ?)', [descuento_x_pago, idprestamo]);
            }
            const cuota_pago = await pool.query(`
                SELECT 
                    C.abono AS abono,
                    C.estado AS estado,
                    C.idcuota AS idcuota
                FROM tblcuotas AS C
                INNER JOIN tblprestamos AS P ON C.idprestamoFK = P.idprestamo
                WHERE P.idprestamo = ?`, [idprestamo]);
  
            for (let i = 0; i < cuota_pago.length; i++) {
                const pago_x_cuota = await pool.query(`
                SELECT 
                    IFNULL(SUM(PO.pago), 0) AS pago_x_cuota
                FROM tblcuotas AS C 
                LEFT JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                WHERE C.idcuota = ?;
                `, [cuota_pago[i].idcuota]);
              
                if (cuota_pago[i].estado === 1) {
                    if (pago >= parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 2]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota, cuota_pago[i].idcuota]);
        
                        if (pago === parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                            break;
                        }
                        pago = parseFloat((pago - (cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota)).toFixed(3));
                    } else if (pago < parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 3]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [pago, cuota_pago[i].idcuota]);
                        break;
                    }
                } else if (cuota_pago[i].estado === 3) {
                    if (pago >= parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 2]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota, cuota_pago[i].idcuota]);
                    if (pago === parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                        break;
                    }
                    pago = parseFloat((pago - (cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota)).toFixed(3));
                } else if (pago < parseFloat((cuota_pago[i].abono -  pago_x_cuota[0].pago_x_cuota).toFixed(3))) {
                    await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 3]);
                    await pool.query('CALL pa_insertar_pagos (?, ?)', [pago, cuota_pago[i].idcuota]);
                    break;
                }
            }
        }
        const estado_prestamo = await pool.query(`SELECT estado FROM tblprestamos WHERE idprestamo = ?`, [idprestamo]);
        if (estado_prestamo[0].estado === '0') {
            res.json({ mensaje: 'Cuotas canceladas' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
      }
    } catch (error) {
      console.log(error);
    }
});
  
router.get('/graph_loan/:fecha', async(req, res) => {
    try {
        const fecha = req.params.fecha;
        console.log(fecha)
        const ganancia_mes = await pool.query(`
        SELECT 
            CONCAT(YEAR(C.fecha_pago), '-', 
            CASE MONTH(C.fecha_pago)
            WHEN 1 THEN 'Ene'
            WHEN 2 THEN 'Feb'
            WHEN 3 THEN 'Mar'
            WHEN 4 THEN 'Abr'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'Jun'
            WHEN 7 THEN 'Jul'
            WHEN 8 THEN 'Ago'
            WHEN 9 THEN 'Sep'
            WHEN 10 THEN 'Oct'
            WHEN 11 THEN 'Nov'
            WHEN 12 THEN 'Dic'
            END) AS año_mes,
        ROUND(SUM(CASE WHEN M.simbolo = 'C$' THEN P.intereses / P.plazo ELSE 0 END), 3)AS ganancia_mes_cordoba,
        ROUND(SUM(CASE WHEN M.simbolo = '$' THEN P.intereses / P.plazo ELSE 0 END), 3) AS ganancia_mes_dolar
        FROM tblprestamos AS P 
        INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
        INNER JOIN tblcuotas AS C ON P.idprestamo = C.idprestamoFK
        WHERE YEAR(C.fecha_pago) = ?
        GROUP BY YEAR(C.fecha_pago), MONTH(C.fecha_pago)
        ORDER BY C.fecha_pago ASC;`, [req.params.fecha]);
      
        const monto_prestado_mes = await pool.query(`
        SELECT 
            CONCAT(YEAR(P.fecha_registro), '-', 
            CASE MONTH(P.fecha_registro)
            WHEN 1 THEN 'Ene'
            WHEN 2 THEN 'Feb'
            WHEN 3 THEN 'Mar'
            WHEN 4 THEN 'Abr'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'Jun'
            WHEN 7 THEN 'Jul'
            WHEN 8 THEN 'Ago'
            WHEN 9 THEN 'Sep'
            WHEN 10 THEN 'Oct'
            WHEN 11 THEN 'Nov'
            WHEN 12 THEN 'Dic'
            END) AS año_mes,
        ROUND(SUM(CASE WHEN M.simbolo = 'C$' THEN P.monto ELSE 0 END), 3)AS prestamo_cordoba,
        ROUND(SUM(CASE WHEN M.simbolo = '$' THEN P.monto ELSE 0 END), 3) AS prestamo_dolar
        FROM tblprestamos AS P 
        INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
        WHERE YEAR(P.fecha_registro) = ?
        GROUP BY YEAR(P.fecha_registro), MONTH(P.fecha_registro)
        ORDER BY P.fecha_registro ASC;`, [req.params.fecha]);
        res.json({ganancia_mes, monto_prestado_mes});   
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al obtener los datos' });
    }
});

router.get('/reports', (req, res) => {
    res.render('admin/reports')

});

var obtener_detalle_prest = {
    "filtrar_todo": [],
    "total_todo": []
  };
router.get('/filter-excel', async (req, res) => {
    try {
        const detalle_prestamo = await pool.query(`CALL Filtrar_Detalle_Prestamos(?, ?)`, [req.query.fecha_inicio, req.query.fecha_fin]);
        const obtener_detalle_total_prestamo = async (f_inicio, f_fin, simbolo) => {
            return await pool.query(`
            SELECT 
                IFNULL(CONCAT(M.simbolo, '', SUM(P.monto)), 0) AS monto,
                IFNULL(CONCAT(M.simbolo, '', SUM(P.intereses)), 0) AS intereses,
                IFNULL(CONCAT(M.simbolo, '', SUM(P.intereses + P.monto)), 0) AS total
            FROM tblprestamos AS P 
            INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
            WHERE M.simbolo = ? AND P.fecha_registro BETWEEN ? AND ?;
            `, [simbolo, f_inicio, f_fin]);
        }
        for(let i = 0; i< detalle_prestamo[0].length; i++){
            obtener_detalle_prest.filtrar_todo.push(detalle_prestamo[0]);
        }
        const detalle_total_prestamo_dolar = await obtener_detalle_total_prestamo(req.query.fecha_inicio, req.query.fecha_fin, '$');
        const detalle_total_prestamo_cordoba = await obtener_detalle_total_prestamo(req.query.fecha_inicio, req.query.fecha_fin, 'C$');
        obtener_detalle_prest.total_todo.push(detalle_total_prestamo_dolar[0], detalle_total_prestamo_cordoba[0]);
        console.log(obtener_detalle_prest.total_todo[0].monto)
        res.json({detalle_prestamo, detalle_total_prestamo_dolar, detalle_total_prestamo_cordoba});
    
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al obtener los datos' });
    }
});

router.get('/generar-excel', async (req, res) => {
    try {
        console.log(obtener_detalle_prest.total_todo)
        const workbook = new Excel.Workbook();
        const worksheet = workbook.addWorksheet('Detalle Prestamos');
    
        const subheaders = [
            ['#', 'Código', 'Cliente', 'Fecha desembolso', 'Fechas de cuotas', '', 'Principal', '', '', '', 'Intereses', '', 'Totales', ''],
            ['', '', '', '', 'Inicio', 'Fin', 'C$', '$', 'Plazo/Meses', 'Tasa interés', 'C$', '$', 'C$', '$'],
        ];

        // Insert two blank rows before the subheaders
        worksheet.insertRow(1, []);
        worksheet.insertRow(2, []);
    
        subheaders.forEach((subheaderRow) => {
            const row = worksheet.addRow(subheaderRow);
            row.eachCell((cell) => {
                cell.font = { bold: true, size: 14, color: { argb: 'FFFFFFFF' } }; // Set size to 14 and color to white (FFFFFFFF)
                cell.alignment = { vertical: 'middle', horizontal: 'center' };
                cell.border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
                cell.fill = {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: '00BFFF' }, // Set the fill color to light blue (00BFFF)
                };
            });
        });
    
        worksheet.mergeCells('E3:F3'); // Fusionar celdas del subencabezado "Fechas de cuotas"
        worksheet.mergeCells('G3:H3'); // Fusionar celdas del subencabezado "Principal"
        worksheet.mergeCells('K3:L3'); // Fusionar celdas del subencabezado "Tasa interés"
        worksheet.mergeCells('M3:N3'); // Fusionar celdas del subencabezado "Intereses"
    
        // Obtener los datos de la tabla desde la variable obtener_detalle_prest.filtrar_todo
        const detallePrestamoData = obtener_detalle_prest.filtrar_todo[0];
    
        // Agregar los datos de la tabla al archivo Excel
        let contador = 1;
        for (item of detallePrestamoData) {
            worksheet.addRow([
                contador++,
                item.codigo_prestamo,
                item.nombre,
                item.fecha_desembolso,
                item.fecha_inicio,
                item.fecha_fin,
                item.monto_cordoba,
                item.monto_dolar,
                item.plazo,
                item.taza_intereses,
                item.intereses_cordoba,
                item.intereses_dolar,
                item.total_cordoba,
                item.total_dolar,
            ]);
        }
    
        worksheet.addRow([
            'Total',
            '',
            '',
            '',
            '',
            '',
            obtener_detalle_prest.total_todo[1].monto,
            obtener_detalle_prest.total_todo[0].monto,
            '',
            '',
            obtener_detalle_prest.total_todo[1].intereses,
            obtener_detalle_prest.total_todo[0].intereses,
            obtener_detalle_prest.total_todo[1].total,
            obtener_detalle_prest.total_todo[0].total
        ]);
        // Configurar el estilo de la tabla
        worksheet.eachRow({ includeEmpty: false }, (row, rowNumber) => {
            row.eachCell((cell) => {
                cell.alignment = { vertical: 'middle', horizontal: 'center' };
                cell.font = { size: 14, bold: false };
                cell.border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
            });
        });
    
        // Definir el nombre del archivo Excel
        const excelFileName = 'detalle_prestamos.xlsx';
    
        // Enviar el archivo Excel como descarga al cliente
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=' + excelFileName);
        return workbook.xlsx.write(res).then(() => {
            res.status(200).end();
        });
        //res.json({ mensaje: 'Estamos bien' });
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al obtener los datos' });
    }
});

// Logout
router.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});
module.exports = router;