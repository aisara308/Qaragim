require('dotenv').config();
const app = require('./app');
const db=require('./config/db')
UserModel=require('./model/user_model')

const port = process.env.PORT || 3000;

app.get('/',(req,res)=>{
    res.send("Hello!")
});

app.listen(port,'0.0.0.0', ()=>
    console.log(`Server running on all interfaces`)
);