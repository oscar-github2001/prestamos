const pool = require('../config/database');
module.exports = {
    verificar: async (nombre_campo, valor_campo, nombre_tabla) => {
        return await pool.query(`
            SELECT COUNT(*) AS existe_registro
            FROM ${nombre_tabla}
            WHERE ${nombre_campo} = ?;
        `, [valor_campo]);
    }
};

