const UserService = require('../services/user_services');
const jwt = require('jsonwebtoken');
const UserModel= require('../model/user_model')
const NovelModel=require('../model/novel_model')
const UserAchievementModel = require('../model/achievement_model');

exports.unlockAchievement = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if(!authHeader) return res.status(401).json({message:'No token'});

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');

        const email = decoded.email;
        const { slug, achievement } = req.body;

        const user = await UserModel.findOne({email});
        if(!user) return res.status(404).json({message:'User not found'});

        let userAchievements = await UserAchievementModel.findOne({ user: user._id });

        /// если нет вообще
        if(!userAchievements){
            userAchievements = await UserAchievementModel.create({
                user: user._id,
                novels: [{
                    novelSlug: slug,
                    achievements: [achievement]
                }]
            });

            return res.status(200).json({status:"unlocked"});
        }

        /// ищем новеллу
        let novelBlock = userAchievements.novels.find(n => n.novelSlug === slug);

        /// если нет блока новеллы
        if(!novelBlock){
            userAchievements.novels.push({
                novelSlug: slug,
                achievements: [achievement]
            });

            await userAchievements.save();
            return res.status(200).json({status:"unlocked"});
        }

        /// проверяем есть ли уже
        const exists = novelBlock.achievements.find(a => a.slug === achievement.slug);

        if(exists){
            return res.status(200).json({status:"already_unlocked"});
        }

        /// добавляем
        novelBlock.achievements.push(achievement);

        await userAchievements.save();

        return res.status(200).json({status:"unlocked"});

    } catch(err){
        console.log(err);
        res.status(500).json({message:'Achievement unlock error'});
    }
};

exports.getUserAchievements = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) return res.status(401).json({ message: 'No token' });

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        const email = decoded.email;

        const user = await UserModel.findOne({ email });
        if (!user) return res.status(404).json({ message: 'User not found' });

        const userAchievements = await UserAchievementModel.findOne({ user: user._id });

        if (!userAchievements) {
            return res.status(200).json({ novels: [] });
        }

        return res.status(200).json({ novels: userAchievements.novels });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Failed to fetch achievements' });
    }
};