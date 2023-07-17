const express = require("express");
const path = require("path");
const ejs = require("ejs");
const morgan = require('morgan');
const session = require('express-session');
const flash = require('connect-flash');
const MySQLStore = require('express-mysql-session')(session);
const {database} = require('./src/keys');

//console.log(config.PORT); // Acceso a la variable PORT
//Inicialización
const app = express();
//Settings
//app.set("port", process.env.PORT || PORT);
//app.set('port', process.env.PORT || 5000);
app.set("views", path.join(__dirname, "src", "views"));
app.set("view engine", "ejs");

//Middlewares
app.use(session({
  secret: 'faztmysqlnodemysql',
  resave: false,
  saveUninitialized: false,
  rolling: true,
  store: new MySQLStore(database)
}));

app.use(flash());
app.use(morgan('dev'));
app.use(express.urlencoded({extended: false})); //Recibir String
app.use(express.json()); //Trabajar con JSON

// Global variables
app.use((req, res, next) => {
  app.locals.success = req.flash('success');
  app.locals.message = req.flash('message');
  app.locals.usuario = req.session;
  if (req.session.loggedin) {
    app.locals.usuario = req.session;
  }
  next();
});

//Routes
const adminRoutes = require("./src/routes/admin");
app.use("/admin", adminRoutes);
const webRoutes = require("./src/routes/web");
app.use("/", webRoutes);

//Public
app.use(express.static(path.join(__dirname, "src", "public")));
const PORT = process.env.PORT || 5000
app.listen(PORT, () => {
    console.log("http://localhost:"+PORT)
})
