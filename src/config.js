const dbhost = process.env.dbhost || 'localhost'
const dbuser = process.env.dbuser || 'root'
const dbpassword = process.env.dbpassword || ''
const dbname = process.env.dbname || 'final'
const dbport = /*process.env.dbport || */3306

module.exports = { dbhost, dbuser, dbpassword, dbname, dbport};