const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const achievementSchema = new Schema({
    name: String,
    slug: String,
    description: String
}, {_id:false});

const novelAchievementsSchema = new Schema({
    novelSlug: { type: String, required: true },
    achievements: [achievementSchema]
}, {_id:false});

const userAchievementSchema = new Schema({
    user: { type: Schema.Types.ObjectId, ref: 'user', required: true, unique: true },
    novels: [novelAchievementsSchema]
});

const UserAchievementModel = db.model('userAchievement', userAchievementSchema);

module.exports = UserAchievementModel;