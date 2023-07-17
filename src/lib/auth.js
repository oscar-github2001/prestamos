module.exports = {
    isLoggedIn(req, res, next) {
        if(req.session.loggedin){
            return next();
        }
        return res.redirect('/');
    },
    /*isLoggedInAdmin(req, res, next) {
        if(req.isAuthenticated() && req.user.id_rolFK === 1){
            return next();
        }
        return res.redirect('/admin/login');
    },
    isLoggedInClient(req, res, next) {
        if(req.isAuthenticated() && req.user.id_rolFK === 2){
            return next();
        }
        return res.redirect('/admin/login');
    },*/
  /*  isNotLoggedIn(req, res, next) {
        if(!req.isAuthenticated()){
            return next();
        }
        return res.redirect('/admin/');
    },*/
    isNotLoggedIn(req, res, next) {
        if (req.session && req.session.loggedin) {
          res.redirect('/admin/');
        } else {
          next();
        }
      }
      
}