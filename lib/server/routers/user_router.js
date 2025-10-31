const {register} = require('../controller/user_controller');
const UserController=require('../controller/user_controller');

const router = require('express').Router();

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.put('/birthday', UserController.enterbirthday);

module.exports=router;