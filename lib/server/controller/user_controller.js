const UserService = require('../services/user_services');
const jwt = require('jsonwebtoken');
const UserModel= require('../model/user_model')

exports.register = async(req, res, next)=>{
    try{
        const {name,email,password}=req.body;

        const user = await UserService.registerUser(name,email,password);

        let tokenData = {_id: user._id, email: user.email, name: user.name, birthday: user.birthday||null}

        const token = await UserService.generateToken(tokenData, "secretKey","10h")

        res.status(200).json({status:true, token:token, success: "User registered succesfully."}) 
    }catch(error){
        throw error;
    }
}

exports.login = async(req,res,next)=>{
    try{
        const {email,password}=req.body;

        const user = await UserService.checkUser(email);

        if(!user){
            throw new Error("User doesn't exist");
        }
        const isMatch=user.comparePasswords(password);
            
        if(isMatch==false){
            throw new Error("Password InValid");
        }

        let tokenData={_id:user._id, email: user.email, name: user.name, birthday: user.birthday||null}

        const token = await UserService.generateToken(tokenData, "secretKey", "10h")

        res.status(200).json({status:true, token: token})
    }catch(error){
        throw error;
    }
}

exports.enterbirthday = async(req,res,next)=>{
    try{
        const authHeader = req.headers.authorization;
        if(!authHeader){
            return res.status(401).json({message: 'No token'});
        }

        const token = authHeader.split(' ')[1];
            const decoded = jwt.verify(token, process.env.Jwt_SECRET || 'secretKey');

        const email = decoded.email;
        if(!email){
            return res.status(400).json({message: 'Email not found'});
        }

        const {birthday} = req.body;
        if(!birthday){
        return res.status(400).json({message: 'Enter birtday'});
        }

        const updatedUser = await UserModel.findOneAndUpdate(
            {email},
            {birthday},
            {new: true}
        );

        if(!updatedUser){
            return res.status(404).json({message: 'No user'});
        }

        res.status(200).json({
            message: 'birthday added succesfully',
            user: {
                name: updatedUser.name,
                email:updatedUser.email,
                birthday:updatedUser.birthday
            }
        });
    }catch(error){
        throw error;
    }
}
