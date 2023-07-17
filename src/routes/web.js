const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const pool = require('../config/database');
const {isNotLoggedIn, isLoggedIn, isLoggedInAdmin, isLoggedInClient} = require('../lib/auth');
const passwordValidation = require('../lib/passwordValidation');
const Swal = require('sweetalert2');

router.get('/', isNotLoggedIn, (req, res, next) => {
    res.render('web/login')
    
});
router.post('/', isNotLoggedIn, async(req, res, next) => {
    const usuario = req.body.usuario;
    const contrasena = req.body.contrasena;

    rows = await  pool.query('SELECT idrolfk, idusuario, usuario AS nombre, contrasena FROM tblusuarios WHERE usuario = ?', [usuario]);
    if(rows.length == 0){
        rows= await pool.query('SELECT idrolfk, idcliente, nombre, contrasena FROM tblclientes WHERE usuario = ?', [usuario]);
    }
    if (rows.length > 0) {
        const user = rows[0];
        const validarContrasena = await passwordValidation.comparePassword(contrasena, user.contrasena);
        console.log(validarContrasena);
        if(validarContrasena){
            req.session.loggedin = true;
            req.session.usuario = user.idrolFK;
            req.session.userId  = user.idcliente || user.idusuario;
            req.session.name = user.usuario || user.nombre;
            res.redirect('/admin/');
        }
        else{
            req.flash('message', 'Contraseña incorrecta');
            
            res.redirect('/');
        } 
    } else {
        req.flash('message', 'Nombre de usuario incorrecto');
        res.redirect('/');
    }
});
module.exports = router;