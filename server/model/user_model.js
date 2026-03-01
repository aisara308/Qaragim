const mongoose = require('mongoose');
const db = require('../config/db');
const bcrypt = require('bcrypt');
const { type } = require('os');
const { hash } = require('crypto');

const {Schema} = mongoose;



const progressSchema = new Schema({
    novel: { type: Schema.Types.ObjectId, ref: 'novel' },
    sceneIndex: { type: Number, default: 0 },
    dialogueIndex: { type: Number, default: 0 },
    finished: { type: Boolean, default: false }
}, {_id:false});

const userSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    birthday:{
        type: String,
        required: false,
        default:null
    },
    gender: {
        type: String,
        enum: ['Ұл', 'Қыз', 'Басқа']
    },
    resetCode: { type: String },
    resetCodeExpire: { type: Date },
    userNovels: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'novel'
        }
    ],
    progress: [progressSchema]
});

userSchema.pre('save', async function(next) {

    if (!this.isModified('password')) {
        return next();
    }

    this.password = await bcrypt.hash(this.password, 10);
    next();
});

userSchema.methods.comparePasswords = async function(userPassword) {
    try{
        const isMatch=await bcrypt.compare(userPassword,this.password);
        return isMatch;
    }catch(error){
        throw error;
    }
}

const UserModel = db.model('user', userSchema);

module.exports=UserModel;