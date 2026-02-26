const UserController=require('../controller/user_controller');
const NovelController = require('../controller/novel_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = require('express').Router();

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.post('/refresh-token', UserController.refreshToken);
router.put('/reset-password', UserController.resetPassword);

router.put('/update', authMiddleware, UserController.updateAccount);
router.delete('/delete-user', authMiddleware, UserController.deleteAccount);
router.get('/novels', authMiddleware, NovelController.getAllNovels);
router.post('/add-user-novel', authMiddleware, NovelController.addNovelToUser);
router.get('/user-novels', authMiddleware, NovelController.getUserNovels);

module.exports=router;