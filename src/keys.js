const config = require('./config'); 
module.exports = {
    database: {
        host: config.dbhost,
        user: config.dbuser,
        password: config.dbpassword,
        database: config.dbname,
        port: config.dbport
    }
};