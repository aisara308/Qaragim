const mongoose = require('mongoose');
const db = require('../config/db');

const {Schema} = mongoose;

const novelSchema = new Schema({
    title: {type: String, required: true},
    slug:{type: String, required: true,unique:true},
    cover: {type: String, required: true},
    script: {type:Object,required: true}
});

const NovelModel = db.model('novel',novelSchema);
module.exports=NovelModel;