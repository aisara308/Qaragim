const UserController=require('../controller/user_controller');
const NovelController = require('../controller/novel_controller');
const AchievementController=require('../controller/achievement_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = require('express').Router();

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.post('/refresh-token', UserController.refreshToken);
router.put('/reset-password', UserController.verifyResetCode);

router.put('/change-password', authMiddleware, UserController.changePassword);
router.put('/update', authMiddleware, UserController.updateAccount);
router.delete('/delete-user', authMiddleware, UserController.deleteAccount);
router.post('/send-reset-code', UserController.sendResetCode);

router.get('/novels', authMiddleware, NovelController.getAllNovels);
router.post('/add-user-novel', authMiddleware, NovelController.addNovelToUser);
router.get('/user-novels', authMiddleware, NovelController.getUserNovels);
router.get('/script/:slug',authMiddleware, NovelController.getNovelScript);
router.get('/load-progress/:slug',authMiddleware,UserController.getProgress);
router.post('/save-progress',authMiddleware,UserController.saveProgress);
router.post('/reset-progress',authMiddleware,UserController.resetNovelProgress);
router.post('/finish',authMiddleware,UserController.finishNovel);

router.post('/achievement-unlock',authMiddleware,AchievementController.unlockAchievement);
router.get('/my-achievements',authMiddleware,AchievementController.getUserAchievements);

router.post('/create-novel',authMiddleware,NovelController.createNovel);
router.delete('/delete-novel/:slug', authMiddleware, NovelController.deleteNovel);

module.exports=router;