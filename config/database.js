const { connect } = require('http2');
const mysql = require('mysql');
const {promisify} = require('util');
const {database} = require('../../keys');

const pool = mysql.createPool(database);
pool.getConnection((err, connect) => {
    if(err){
        if (err.code === 'PROTOCOL_CONNECTION_LOST'){
            console.error('LA CONEXIÓN DE LA BASE DE DATOS ESTABA CERRADA');
        }
        if (err.code === 'ER_CON_COUNT_ERROR'){
            console.error('LA BASE DE DATOS TIENE MUCHAS CONEXIONES');
        }
        if (err.code === 'ECONNREFUSED'){
            console.error('LA CONEXIÓN DE LA BASE DE DATOS FUE RECHAZADA');
        }
    }
    if(connect) connect.release();
      console.log('BASE DE DATOS CONECTADA');
    return;
});

//Convirtiendo a promesa lo que antes era un Callback
pool.query = promisify(pool.query);
module.exports = pool;


