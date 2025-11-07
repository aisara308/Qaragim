const UserController=require('../controller/user_controller');
const NovelController = require('../controller/novel_controller');

const router = require('express').Router();

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.put('/birthday', UserController.enterbirthday);
router.put('/update', UserController.updateAccount);
router.put('/reset-password', UserController.resetPassword);
router.delete('/delete-user',UserController.deleteAccount);
router.get('/novels', NovelController.getAllNovels);
router.post('/add-user-novel', NovelController.addNovelToUser);
router.get('/user-novels',NovelController.getUserNovels);

module.exports=router;