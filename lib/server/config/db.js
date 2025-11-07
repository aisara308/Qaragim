const mongoose = require('mongoose');


const connection=mongoose.createConnection('mongodb+srv://aisara:1234@cluster0.4uy1zev.mongodb.net/?appName=Cluster0').on('open',()=>{
    console.log("MongoDB connected.");
}).on('error',()=>{
    console.log("MongoDB connection error.");
});

module.exports = connection;