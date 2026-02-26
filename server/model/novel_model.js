const mongoose = require('mongoose');
const db = require('../config/db');

const {Schema} = mongoose;

const novelSchema = new Schema({
    title: {type: String, required: true},
    cover: {type: String, required: true},
    folder: {type: String, required:true}
});

const NovelModel = db.model('novel',novelSchema);
module.exports=NovelModel;