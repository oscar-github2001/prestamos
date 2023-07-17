const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const pool = require('../config/database');
const {isNotLoggedIn, isLoggedIn, isLoggedInAdmin, isLoggedInClient} = require('../lib/auth');
const passwordValidation = require('../lib/passwordValidation');
const e = require('connect-flash');
const { jsPDF } = require('jspdf');

router.get('/', isLoggedIn, (req, res) => {
    res.render('admin/start');
});

//Clientes
router.get('/client'/*, isLoggedIn*/, async(req, res) => {
    try {
        const ciudades = await pool.query(`SELECT * FROM tblciudad`);
        const clientes = await pool.query(`SELECT   idcliente, 
                                                    CONCAT(nombre, ' ', apellido) AS nombre 
                                                FROM tblclientes
                                                WHERE estado = 1`);
        res.render('admin/client', {ciudades, clientes});
    } catch (error) {
        console.log(error);
    }
});

router.get("/table_client/:estado", /*isLoggedIn,*/ async(req, res) => {
    const estado = req.params.estado;
    await pool.query(`
        SELECT 
            idcliente,
            CONCAT(nombre, ' ', apellido) AS nombre_completo,
            direccion,
            celular, 
            estado
        FROM tblclientes
        WHERE estado = ?`,[estado], function(error, resultado) {
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
    const id = req.params.id;
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
        WHERE idcliente = ?`, [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
        }
    });
});

router.get('/edit_client_ciudad', async(req, res) => {
    await pool.query(`SELECT 
                        idciudad,
                        nombre
                    FROM tblciudad`, function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado);
        }
    });
});

router.post('/update_client', async(req, res) => {
    console.log(req.body)
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
    
    await pool.query(`UPDATE tblclientes
                             SET nombre = ?,
                                 apellido = ?,
                                 cedula = ?,
                                 celular = ?,
                                 direccion = ?,
                                 fecha_nacimiento = ?,
                                 estado_civil = ?,
                                 usuario = ?,
                                 sexo = ?,
                                 idciudadFK = ?
                            WHERE idcliente = ?`,
                                [nombre, 
                                apellido,
                                cedula, 
                                celular, 
                                direccion, 
                                fecha_nacimiento, 
                                estado_civil, 
                                usuario, 
                                sexo, 
                                idciudad, 
                                idcliente], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
        }
    });
});

router.post('/update_client_state/:id',/* isLoggedIn,*/ async(req, res) => {
    const id = req.params.id;
    let estado = await pool.query('SELECT estado FROM tblclientes WHERE idcliente = ?', [id]);
    if(estado[0].estado == 1){
        estado = 0;
    }
    else if(estado[0].estado == 0){
        estado = 1;
    }
    await pool.query('CALL pa_actualizar_cliente_estado(?, ?)', [id, estado], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al actualizar los datos' });
        } else {
            res.json({ mensaje: 'Datos actualizados correctamente' });
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
    const id = req.params.id;
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
                    LIMIT 1`, [id], function(error, resultado) {
        if (error) {
            console.log(error);
            res.status(500).json({ mensaje: 'Error al obtener los datos' });
        } else {
            res.json(resultado[0]);
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
    const id = req.params.id;
    let estado = await pool.query('SELECT estado FROM tblusuarios WHERE idusuario = ?', [id]);
    if(estado[0].estado == 1){
        estado = 0;
    }
    else if(estado[0].estado == 0){
        estado = 1;
    }
    await pool.query('CALL pa_actualizar_usuario_estado(?, ?)', [id, estado], function(error, resultado) {
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
    const formapago = 1;
    const cliente = req.body.cliente;
    const tipoprestamo = req.body.tipoprestamo;
    const interes = req.body.interes;
    const plazo = parseInt(req.body.plazo);
    const monto = parseFloat(req.body.monto);
    const idusuarioFK = req.session.userId;
    const moneda = req.body.moneda;
    const fecha_desembolso = req.body.fecha_registro;
    let codigo = await pool.query('SELECT MAX(idprestamo + 1) AS idprestamo FROM tblprestamos');
    const valor_interes = await pool.query('SELECT ROUND(descripcion / 100, 3) AS valor_interes FROM tblintereses WHERE idinteres = ?', [interes]);
    if(codigo[0].idprestamo == null){
        codigo = '0001';
    }
    else{
        if((codigo[0].idprestamo.toString()).length === 1){
            codigo = '000' + parseInt(codigo[0].idprestamo);
        }
        else if((codigo[0].idprestamo.toString()).length === 2){
            codigo =  '00' + parseInt(codigo[0].idprestamo);
        }
        else if((codigo[0].idprestamo.toString()).length === 3){
            codigo = '0'+codigo;
        }
    }

    let intereses = monto;
    let sumainterescorriente = 0;
    for(let i=0; i <  parseInt(plazo); i++){
        sumainterescorriente += (intereses * valor_interes[0].valor_interes);
        intereses -= parseFloat(monto/plazo);
    }
    try {
        const insertar_prestamo =   await pool.query(`  
        INSERT INTO tblprestamos 
            (codigo,
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
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [
            codigo, 
            tipoprestamo, 
            cliente, 
            idusuarioFK, 
            interes, 
            formapago, 
            monto, 
            plazo,
            sumainterescorriente,
            moneda,
            fecha_desembolso ]);
        const fecha_registro =  await pool.query (`SELECT fecha_registro FROM tblprestamos WHERE idprestamo = ?`, [insertar_prestamo.insertId]);
        fecha_pago = fecha_registro[0].fecha_registro;
   
        intereses = monto;
        for(let i=0; i <  parseInt(plazo); i++){
            await pool.query (`
            CALL pa_insertar_cuotas (?, ?, ?, ?, ?, ?)`, [ 
            insertar_prestamo.insertId, 
            i+1, 
            new Date(fecha_pago.setMonth(fecha_pago.getMonth() + 1)), 
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
                M.simbolo AS simbolo
            FROM tblprestamos AS P INNER JOIN tblclientes AS C
            ON P.idclienteFK = C.idcliente
            INNER JOIN tbltipoprestamos AS T
            ON P.idtipoprestamoFK = T.idtipoprestamo
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            ORDER BY P.idprestamo ASC`);
        let saldo_pendiente = 0;
        for(let i = 0; i < resultado.length; i++){
            let detalle_sumaabono  =  await pool.query (`
                SELECT   
                    SUM(C.abono) AS abono
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);
            let detalle_sumapago  =  await pool.query (`
                SELECT   
                    SUM(PO.pago) AS pago
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                INNER JOIN tblpagos AS PO
                ON C.idcuota = PO.idcuotaFK
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);
            if(detalle_sumapago[0].pago === null){
                detalle_sumapago = 0;
            }
            else{
                detalle_sumapago = detalle_sumapago[0].pago;
            } 
            saldo_pendiente = resultado[i].simbolo +''+ (detalle_sumaabono[0].abono - detalle_sumapago).toFixed(3);
            resultado[i].saldo_pendiente = saldo_pendiente;
        }
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.get("/table_loan/:id", async(req, res) => {
    let id = req.params.id;
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
                M.simbolo AS simbolo
            FROM tblprestamos AS P INNER JOIN tblclientes AS C
            ON P.idclienteFK = C.idcliente
            INNER JOIN tbltipoprestamos AS T
            ON P.idtipoprestamoFK = T.idtipoprestamo
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            WHERE P.estado = ?
            ORDER BY P.idprestamo ASC`, [id]);
        let saldo_pendiente = 0;
        for(let i = 0; i < resultado.length; i++){
            let detalle_sumaabono  =  await pool.query (`
                SELECT   
                    SUM(C.abono) AS abono
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);

            let detalle_sumapago  =  await pool.query (`
                SELECT   
                    SUM(PO.pago) AS pago
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                INNER JOIN tblpagos AS PO
                ON C.idcuota = PO.idcuotaFK
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);
            if(detalle_sumapago[0].pago === null){
                detalle_sumapago = 0;
            }
            else{
                detalle_sumapago = detalle_sumapago[0].pago;
            } 
            saldo_pendiente = resultado[i].simbolo +''+ (detalle_sumaabono[0].abono - detalle_sumapago).toFixed(3);
            resultado[i].saldo_pendiente = saldo_pendiente;
            
        }
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.get("/get_quota/:id", async(req, res) => {
    const id = req.params.id;
    try {
        let resultado =   await pool.query(`
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
            WHERE idprestamo = ?  `, [id]);

        let detalle_sumapago  =  await pool.query (`  
            SELECT   
                SUM(PO.pago) AS sumapago
            FROM tblcuotas AS C INNER JOIN tblprestamos AS P
            ON C.idprestamoFK = P.idprestamo
            INNER JOIN tblpagos AS PO
            ON C.idcuota = PO.idcuotaFK
            WHERE idprestamo = ?`,  [id]);

        if(detalle_sumapago[0].sumapago === null){
            detalle_sumapago = 0;
        }else{
            detalle_sumapago = detalle_sumapago[0].sumapago;
        }

        let detalle_sumadescuento = await pool.query(`  
            SELECT
                SUM(D.descuento) AS descuento
            FROM tbldescuento AS D
            INNER JOIN tblprestamos AS P
            ON D.idprestamoFK = P.idprestamo
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            WHERE P.idprestamo = ?`, [id]);
        if(detalle_sumadescuento[0].descuento === null){
            detalle_sumadescuento = 0;
        }else{
            detalle_sumadescuento = detalle_sumadescuento[0].descuento;
        }
        let detalle_resultado  =  await pool.query (`
            SELECT   
                P.idprestamo AS idprestamo, 
                P.codigo AS codigo,
                CONCAT(M.simbolo, SUM(C.capital)) AS capital, 
                CONCAT(M.simbolo, SUM(C.interescorriente)) AS interescorriente,
                CONCAT(M.simbolo, SUM(C.abono)) AS abono,
                SUM(C.abono) AS abono_pendiente,
                CONCAT(CL.nombre, ' ', CL.apellido) AS cliente,
                DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
                DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') AS fecha_fin,
                CONCAT(M.simbolo, P.monto) AS monto,
                P.plazo AS plazo,
                CONCAT(I.descripcion,'%     ', SUBSTRING(I.descripcion/100, 1, 5)) AS interes,
                P.estado AS estado,
                M.simbolo AS simbolo
            FROM tblcuotas AS C INNER JOIN tblprestamos AS P
            ON C.idprestamoFK = P.idprestamo
            INNER JOIN tblclientes AS CL
            ON P.idclienteFK = CL.idcliente
            INNER JOIN tblintereses AS I
            ON P.idinteresFK = I.idinteres
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            WHERE idprestamo = ?`,  [id]);
        detalle_resultado[0].saldo_pendiente = detalle_resultado[0].simbolo +' '+(detalle_resultado[0].abono_pendiente - detalle_sumapago).toFixed(3);
        detalle_resultado[0].detalle_sumadescuento = detalle_resultado[0].simbolo +' '+ detalle_sumadescuento.toFixed(3);
        res.json({resultado, detalle_resultado, detalle_sumapago});
    } catch (error) {
        console.log(error);
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
    const id = req.params.id;
    try {
        const resultado = await pool.query(`
            SELECT
                P.idprestamo AS idprestamo,
                P.codigo AS codigo, 
                CONCAT(C.nombre, ' ', C.apellido) AS cliente,
                CONCAT(simbolo, P.monto) AS monto,
                CONCAT(M.simbolo, P.intereses) AS intereses,
                CONCAT(M.simbolo, SUM(CU.abono)) AS total,
                M.simbolo AS simbolo
            FROM tblprestamos AS P 
            INNER JOIN tblclientes AS C
            ON P.idclienteFK = C.idcliente
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            INNER JOIN tblcuotas AS CU
            ON P.idprestamo = CU.idprestamoFK
            WHERE C.idcliente = ? AND P.estado = 1
            GROUP BY P.idprestamo`, [id]);
        let saldo_pendiente = 0;
        for(let i = 0; i < resultado.length; i++){
            let detalle_sumaabono  =  await pool.query (`
                SELECT   
                    SUM(C.abono) AS abono
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);

            let detalle_sumapago  =  await pool.query (`
                SELECT   
                    SUM(PO.pago) AS pago
                FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                ON C.idprestamoFK = P.idprestamo
                INNER JOIN tblpagos AS PO
                ON C.idcuota = PO.idcuotaFK
                WHERE idprestamo = ?`,  [resultado[i].idprestamo]);
            if(detalle_sumapago[0].pago === null){
                detalle_sumapago = 0;
            }
            else{
                detalle_sumapago = detalle_sumapago[0].pago;
            } 
            saldo_pendiente = resultado[i].simbolo +''+ (detalle_sumaabono[0].abono - detalle_sumapago).toFixed(3);
            resultado[i].saldo_pendiente = saldo_pendiente;
        }
        res.json(resultado);
    } catch (error) {
        console.log(error);
    }
});

router.post("/get_payments_quotas", async(req, res) => {
    const id = req.body.det_idprestamo;
    try {
        let descuento = await pool.query(`  
            SELECT 
                SUM(D.descuento) AS descuento
            FROM tbldescuento AS D
            INNER JOIN tblprestamos AS P
            ON D.idprestamoFK = P.idprestamo
            WHERE P.idprestamo = ?`, [id]);
        descuento = descuento[0].descuento || 0
    
        const ultima_cuota = await pool.query(` 
            SELECT 
                MAX(idcuota) AS ultima_cuota
            FROM tblprestamos AS P
            INNER JOIN tblcuotas AS C
            ON P.idprestamo = C.idprestamoFK
            WHERE P.idprestamo = ?`, [id]);
        let abono = await pool.query(`  
            SELECT 
                C.abono - SUM(PO.pago) AS abono
            FROM tblprestamos AS P
            INNER JOIN tblcuotas AS C
            ON P.idprestamo = C.idprestamoFK
            INNER JOIN tblpagos AS PO
            ON PO.idcuotaFK = C.idcuota
            WHERE C.idcuota = ?`, [ultima_cuota[0].ultima_cuota]);
        
        if(abono[0].abono === null){
            abono = await pool.query(`  
                SELECT 
                    C.abono AS abono
                FROM tblprestamos AS P
                INNER JOIN tblcuotas AS C
                ON P.idprestamo = C.idprestamoFK
                WHERE idprestamo = ?
                LIMIT 1`, [id]);
            abono = abono[0].abono;
            res.json(abono);
        }
        else{
            abono = (abono[0].abono - descuento).toFixed(3);
            console.log(abono)
            res.json(abono);
        }
    } catch (error) {
        console.log(error);
    }
});

router.post("/payments_quotas", async (req, res) => {
    try {
        let pago = parseFloat(parseFloat(req.body.det_pago).toFixed(3));
        let total_descuento = parseFloat(req.body.det_saldo_descuento.split(" ")[1]);
        let descuento_pago = parseFloat(parseFloat(req.body.det_descuento || 0).toFixed(3));
        const idprestamo = req.body.det_idprestamo;

        let suma_pago = await pool.query(`
            SELECT 
            CAST(SUM(PO.pago) AS DECIMAL(10, 3)) AS suma_pago
            FROM tblprestamos AS P 
            INNER JOIN tblcuotas AS C ON P.idprestamo = C.idprestamoFK	
            INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
            WHERE P.idprestamo = ?`, [idprestamo]);
  
        suma_pago = suma_pago[0].suma_pago || 0;

        const total = await pool.query(`
            SELECT 
            ROUND(SUM(C.abono), 3) AS abono
            FROM tblprestamos AS P
            INNER JOIN tblcuotas AS C ON P.idprestamo = C.idprestamoFK
            WHERE idprestamo = ?`, [idprestamo]);
  
        const totalAbono = total[0].abono;
    
        pago += descuento_pago;
        console.log((pago + suma_pago).toFixed(3));
    
        if (pago + suma_pago > totalAbono) {
            res.json({ mensaje: 'La cantidad ingresada es mayor a lo que debes en el prestamo' });
        } else {
            if (descuento_pago != 0) {
                await pool.query('INSERT INTO tbldescuento (descuento, idprestamoFK) VALUES (?, ?)', [descuento_pago, idprestamo]);
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
                let suma = await pool.query(`
                    SELECT 
                        ROUND(SUM(PO.pago), 3) AS sumatorio
                    FROM tblcuotas AS C
                    INNER JOIN tblpagos AS PO ON C.idcuota = PO.idcuotaFK
                    WHERE C.idcuota = ?`, [cuota_pago[i].idcuota]);
        
                suma = suma[0].sumatorio || 0;
    
                if (cuota_pago[i].estado === 1) {
                    if (pago >= parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 2]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [cuota_pago[i].abono - suma, cuota_pago[i].idcuota]);
        
                        if (pago === parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                            break;
                        }
                        pago = parseFloat((pago - (cuota_pago[i].abono - suma)).toFixed(3));
                    } else if (pago < parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 3]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [pago, cuota_pago[i].idcuota]);
                        break;
                    }
                } else if (cuota_pago[i].estado === 3) {
                    if (pago >= parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                        await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 2]);
                        await pool.query('CALL pa_insertar_pagos (?, ?)', [cuota_pago[i].abono - suma, cuota_pago[i].idcuota]);
                    if (pago === parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                        break;
                    }
                    pago = parseFloat((pago - (cuota_pago[i].abono - suma)).toFixed(3));
                } else if (pago < parseFloat((cuota_pago[i].abono - suma).toFixed(3))) {
                    await pool.query(`CALL pa_actualizar_cuotas_estado (?, ?)`, [cuota_pago[i].idcuota, 3]);
                    await pool.query('CALL pa_insertar_pagos (?, ?)', [pago, cuota_pago[i].idcuota]);
                    break;
                }
            }
        }
        const pagos_cancelados = await pool.query(`
            SELECT 
                idcuota
            FROM tblcuotas AS C
            INNER JOIN tblprestamos AS P ON C.idprestamoFK = P.idprestamo
            WHERE P.idprestamo = ? AND C.estado = 2`, [idprestamo]);
  
        if (cuota_pago.length === pagos_cancelados.length) {
            await pool.query(`CALL pa_actualizar_prestamos_estado (?, ?)`, [idprestamo, 0]);
    
            res.json({ mensaje: 'Cuotas canceladas' });
        } else {
            res.json({ mensaje: 'Datos guardados correctamente' });
        }
      }
    } catch (error) {
      console.log(error);
    }
});
  
router.get('/graph_loan', async(req, res) => {
    try {
        const ganancia_mes = await pool.query(`
        SELECT 
            CONCAT(YEAR(C.fecha_pago), '-', 
            CASE MONTH(C.fecha_pago)
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
            END) AS año_mes,
        ROUND(SUM(CASE WHEN M.simbolo = 'C$' THEN P.intereses / P.plazo ELSE 0 END), 3)AS ganancia_mes_cordoba,
        ROUND(SUM(CASE WHEN M.simbolo = '$' THEN P.intereses / P.plazo ELSE 0 END), 3) AS ganancia_mes_dolar
        FROM tblprestamos AS P 
        INNER JOIN tblmoneda AS M ON P.idmonedaFK = M.idmoneda
        INNER JOIN tblcuotas AS C ON P.idprestamo = C.idprestamoFK
        GROUP BY YEAR(C.fecha_pago), MONTH(C.fecha_pago)
        ORDER BY C.fecha_pago ASC;`);
      
        const monto_prestado_mes = await pool.query(`
            SELECT 
                CONCAT(YEAR(fecha_registro), '-', 
                    CASE MONTH(P.fecha_registro)
                        WHEN 1 THEN 'Enero'
                        WHEN 2 THEN 'Febrero'
                        WHEN 3 THEN 'Marzo'
                        WHEN 4 THEN 'Abril'
                        WHEN 5 THEN 'Mayo'
                        WHEN 6 THEN 'Junio'
                        WHEN 7 THEN 'Julio'
                        WHEN 8 THEN 'Agosto'
                        WHEN 9 THEN 'Septiembre'
                        WHEN 10 THEN 'Octubre'
                        WHEN 11 THEN 'Noviembre'
                        WHEN 12 THEN 'Diciembre'
                    END) AS año_mes,
                SUM(P.monto) AS monto,
                M.simbolo AS simbolo
            FROM tblprestamos AS P 
            INNER JOIN tblmoneda AS M
            ON P.idmonedaFK = M.idmoneda
            WHERE M.simbolo = '$'
            GROUP BY año_mes`);
        res.json({ganancia_mes, monto_prestado_mes});   
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al obtener los datos' });
    }
});

router.get('/reports', (req, res) => {
    res.render('admin/reports')

});
const fs = require('fs')
const path = require('path');
const axios = require('axios');

router.get('/generar-pdf', async (req, res) => {
    try {
        const resultado = await pool.query(` 
            SELECT 
                DISTINCT C.idcliente AS idcliente,
                CONCAT(C.nombre, ' ', C.apellido) AS nombre
            FROM tblprestamos AS P
            INNER JOIN tblclientes AS C 
            ON P.idclienteFK = C.idcliente
            WHERE P.estado = 1
            GROUP BY nombre`);

        require('jspdf-autotable');
        // Crear una instancia de jsPDF
        const doc = new jsPDF();
    
        // Función para agregar la imagen desde la URL
        async function addImageFromURL(url, x, y, width, height) {
            try {
                const response = await axios.get(url, { responseType: 'arraybuffer' });
                const imageData = Buffer.from(response.data, 'binary');
                doc.addImage(imageData, 'PNG', x, y, width, height);
                // No enviar la respuesta aquí
            } catch (error) {
                console.error(error);
                res.status(500).json({ mensaje: 'Error al cargar la imagen desde la URL' });
            }
        }
        // Cargar la imagen desde la URL
        const logoURL = 'https://www.bbva.com.co/content/dam/public-web/global/images/micro-illustrations/micro_blue_loan_money_time.png.img.320.1635233742382.png'; // URL de la imagen
        const logoWidth = 25; // Ancho deseado de la imagen del logotipo
        const logoHeight = 25; // Alto deseado de la imagen del logotipo

        // Agregar la imagen desde la URL al documento
        await addImageFromURL(logoURL, 15, 10, logoWidth, logoHeight);

        //Vamos agregar la fecha
        let fechaActual = new Date();
        let diasSemana = ['Domingo,', 'Lunes,', 'Martes,', 'Miércoles,', 'Jueves,', 'Viernes,', 'Sábado,'];
        let diaSemana = diasSemana[fechaActual.getDay()];
        let diaMes = fechaActual.getDate();
        let meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
        let mes = meses[fechaActual.getMonth()];
        let anio = fechaActual.getFullYear();
        let horas = fechaActual.getHours();
        let minutos = fechaActual.getMinutes();
        // Convertir a formato AM/PM
        let amPm = horas >= 12 ? ' PM' : ' AM';
        horas = horas % 12;
        horas = horas ? horas : 12;
        let formatoFechaHora = diaSemana + ' ' + diaMes + ' de ' + mes  + ' de ' + anio + ' ' + horas + ':' + (minutos < 10 ? '0' + minutos : minutos) + amPm;

        function  agregarEncabezado(){
            // Definir las coordenadas y dimensiones del rectángulo
            const rectX = 0; // Coordenada X del rectángulo
            const rectY = 5; // Coordenada Y del rectángulo
            const rectWidth = 210; // Ancho del rectángulo
            const rectHeight = 35; // Alto del rectángulo
    
            // Definir el color de relleno del rectángulo
            const fillColor = '#1a66d9'; // Color rojo en formato hexadecimal
            // Establecer el color de relleno
            doc.setFillColor(fillColor);
            // Dibujar el rectángulo sin bordes
            doc.rect(rectX, rectY, rectWidth, rectHeight, 'F');

            doc.setFontSize(9);
            // Obtener el ancho del texto de la fecha
            const fechaWidth = doc.getTextWidth(formatoFechaHora);
            // Obtener el ancho total del documento
            const docWidth = doc.internal.pageSize.getWidth();
            // Calcular la posición x del texto de la fecha en la parte derecha
            const fechaX = docWidth - fechaWidth - 20; // Restar el ancho del texto y un margen de 20
            doc.setTextColor(255, 255, 255);
            // Agregar el texto de la fecha en la parte derecha
            doc.text(formatoFechaHora, fechaX, 15);
    
            // Definir el encabezado de texto
            doc.setFontSize(18);
            doc.setTextColor(255, 255, 255);
            doc.setFont(undefined, 'bold');
            doc.text('Reporte de clientes con prestamos activos', 105, 25, { align: 'center' });
            doc.setFont(undefined, 'normal');
        }
        agregarEncabezado();
        // Agregar la imagen desde la URL al documento
        await addImageFromURL(logoURL, 15, 10, logoWidth, logoHeight);
        let posicionY = 50;
        let p = 48;
        for(i = 0; i < resultado.length; i++){
            console.log(posicionY)
            console.log(doc.internal.pageSize.getHeight())
              // Agregar encabezado en cada nueva página
            if (posicionY >= 186.4166666666666) {
                doc.addPage(); // Agregar nueva página
                agregarEncabezado(); // Agregar encabezado en la nueva página
                await addImageFromURL(logoURL, 15, 10, logoWidth, logoHeight);
                posicionY = 50; // Restablecer la posición Y
                p = 48; // Restablecer el valor de p
            }
            doc.setFontSize(10);
            doc.setTextColor(0, 0, 0);
            doc.setFont(undefined, 'bold');
            doc.text('Cliente:', 20, p);
            doc.setFont(undefined, 'normal');
            doc.text(resultado[i].nombre, 40, p);
            const detalle_prestamo =  await pool.query(`SELECT     
                                                            P.idprestamo AS idprestamo,                   
                                                            P.codigo AS codigo, 
                                                            T.descripcion AS tipoprestamo,
                                                            CONCAT(simbolo, P.monto) AS monto,
                                                            DATE_FORMAT(P.fecha_registro, '%Y-%m-%d') AS fecha_registro,
                                                            DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
                                                            DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') fecha_fin,
                                                            CONCAT(P.plazo, ' meses') AS plazo,
                                                            CONCAT(M.simbolo, P.intereses) AS intereses,
                                                            CONCAT(M.simbolo,  P.monto + P.intereses) AS total,
                                                            M.simbolo AS simbolo
                                                        FROM tblprestamos AS P INNER JOIN tblclientes AS C
                                                        ON P.idclienteFK = C.idcliente
                                                        INNER JOIN tbltipoprestamos AS T
                                                        ON P.idtipoprestamoFK = T.idtipoprestamo
                                                        INNER JOIN tblmoneda AS M
                                                        ON P.idmonedaFK = M.idmoneda
                                                        WHERE C.idcliente = ? AND P.estado = 1`, [resultado[i].idcliente]);
            
            let saldo_pendiente = 0;
            for(let i = 0; i < detalle_prestamo.length; i++){
                let detalle_sumaabono  =  await pool.query (`SELECT   
                                                                SUM(C.abono) AS abono
                                                            FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                                                            ON C.idprestamoFK = P.idprestamo
                                                            WHERE idprestamo = ?`,  [detalle_prestamo[i].idprestamo]);
                let detalle_sumapago  =  await pool.query (`SELECT   
                                                                SUM(PO.pago) AS pago
                                                            FROM tblcuotas AS C INNER JOIN tblprestamos AS P
                                                            ON C.idprestamoFK = P.idprestamo
                                                            INNER JOIN tblpagos AS PO
                                                            ON C.idcuota = PO.idcuotaFK
                                                            WHERE idprestamo = ?`,  [detalle_prestamo[i].idprestamo]);
                if(detalle_sumapago[0].pago === null){
                    detalle_sumapago = 0;
                }
                else{
                    detalle_sumapago = detalle_sumapago[0].pago;
                } 

                saldo_pendiente = detalle_prestamo[i].simbolo +''+ (detalle_sumaabono[0].abono - detalle_sumapago).toFixed(3);
                detalle_prestamo[i].saldo_pendiente = saldo_pendiente;
            }
            const columns = ['Código', 'Tipo de prestamo', 'Monto', 'Intereses', 'Total', 'Saldo pendiente', 'Fecha desembolso', 'Fecha inicio', 'Fecha fin', 'Plazo'];
            const rows = detalle_prestamo.map((row) => [
                { content: row.codigo, styles: { halign: 'center', valign: 'middle' } },
                { content: row.tipoprestamo, styles: { halign: 'center', valign: 'middle' } },
                { content: row.monto, styles: { halign: 'center', valign: 'middle' } },
                { content: row.intereses, styles: { halign: 'center', valign: 'middle' } },
                { content: row.total, styles: { halign: 'center', valign: 'middle' } },
                { content: row.saldo_pendiente, styles: { halign: 'center', valign: 'middle' } },
                { content: row.fecha_registro, styles: { halign: 'center', valign: 'middle' } },
                { content: row.fecha_inicio, styles: { halign: 'center', valign: 'middle' } },
                { content: row.fecha_fin, styles: { halign: 'center', valign: 'middle' } },
                { content: row.plazo, styles: { halign: 'center', valign: 'middle' } },
            ]);

            const options = {
                headerStyles: {
                  fillColor: [74, 81, 78 ], 
                  halign: 'center',
                  fontSize: 8,
                }
            };
            doc.autoTable({
                head: [columns],
                body: rows,
                startY: posicionY,
                ...options,
            });
          /// Obtener el tamaño de la tabla
            const tableSize = doc.autoTable.previous.finalY;

            // Actualizar la posición Y para la siguiente sección
            posicionY = tableSize + 10; // Sumar el tamaño de la tabla y un margen d
            p = tableSize + 8;
        }
        // Obtener los datos del PDF en formato base64
        const pdfData = doc.output('datauristring');

        // Enviar los datos del PDF al cliente para mostrarlo en el navegador
        res.send(`<iframe src="${pdfData}" width="100%" height="500px"></iframe>`);
        // Cerrar la conexión a la base de datos
        //pool.end();

    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: 'Error al obtener los datos' });
    }
});

const ExcelJS = require('exceljs');
router.get('/generar-excel', async (req, res) => {
    try {
        const resultado = await pool.query(`SELECT DISTINCT
                                                C.idcliente AS idcliente,
                                                CONCAT(C.nombre, ' ', C.apellido) AS nombre
                                            FROM tblprestamos AS P
                                            INNER JOIN tblclientes AS C 
                                            ON P.idclienteFK = C.idcliente
                                            WHERE P.estado = 1
                                            GROUP BY nombre`);

        // Crear un nuevo libro de Excel
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Reporte');

        for (i = 0; i < resultado.length; i++) {
            const detalle_prestamo =  await pool.query( `SELECT                         
                                                        P.codigo AS codigo, 
                                                        T.descripcion AS tipoprestamo,
                                                        CONCAT(simbolo, P.monto) AS monto,
                                                        DATE_FORMAT(P.fecha_registro, '%Y-%m-%d') AS fecha_registro,
                                                        DATE_FORMAT(P.fecha_inicio, '%Y-%m-%d') AS fecha_inicio,
                                                        DATE_FORMAT(P.fecha_fin, '%Y-%m-%d') fecha_fin,
                                                        CONCAT(P.plazo, ' meses') AS plazo,
                                                        CONCAT(M.simbolo, P.intereses) AS intereses,
                                                        M.simbolo AS simbolo
                                                    FROM tblprestamos AS P INNER JOIN tblclientes AS C
                                                    ON P.idclienteFK = C.idcliente
                                                    INNER JOIN tbltipoprestamos AS T
                                                    ON P.idtipoprestamoFK = T.idtipoprestamo
                                                    INNER JOIN tblmoneda AS M
                                                    ON P.idmonedaFK = M.idmoneda
                                                    WHERE C.idcliente = ? AND P.estado = 1`, [resultado[i].idcliente]);

            // Definir las columnas del archivo Excel
            const columns = [
                { header: 'Código', key: 'codigo' },
                { header: 'Tipo de préstamo', key: 'tipoprestamo' },
                { header: 'Monto', key: 'monto' },
                { header: 'Intereses', key: 'intereses' },
                { header: 'Fecha desembolso', key: 'fecha_registro' },
                { header: 'Fecha inicio', key: 'fecha_inicio' },
                { header: 'Fecha fin', key: 'fecha_fin' },
                { header: 'Plazo', key: 'plazo' }
            ];

            // Agregar las columnas al archivo Excel
            worksheet.columns = columns;
            let posicionY = 2;
            const rows = detalle_prestamo.map((row) => ({
                codigo: row.codigo,
                tipoprestamo: row.tipoprestamo,
                monto: row.monto,
                intereses: row.intereses,
                fecha_registro: row.fecha_registro,
                fecha_inicio: row.fecha_inicio,
                fecha_fin: row.fecha_fin,
                plazo: row.plazo
            }));

            // Agregar las filas al archivo Excel
            worksheet.addRows(rows, 'n');

            // Actualizar la posición Y para la siguiente sección
            posicionY += detalle_prestamo.length + 2;
        }

        // Guardar el archivo Excel en un buffer
        const buffer = await workbook.xlsx.writeBuffer();

        // Enviar el archivo Excel al cliente para descargarlo
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=reporte.xlsx');
        res.send(buffer);

        // ...
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