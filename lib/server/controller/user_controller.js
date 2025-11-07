const UserService = require('../services/user_services');
const jwt = require('jsonwebtoken');
const UserModel= require('../model/user_model')

exports.register = async(req, res, next)=>{
    try{
        const {name,email,password}=req.body;

        const user = await UserService.registerUser(name,email,password);

        let tokenData = {_id: user._id, email: user.email, name: user.name, birthday: user.birthday||null}

        const token = await UserService.generateToken(tokenData,process.env.JWT_SECRET|| "secret_key",process.env.JWT_EXPIRE || "10h")

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

        const token = await UserService.generateToken(tokenData, process.env.JWT_SECRET|| "secret_key", process.env.JWT_EXPIRE || "10h")

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
        const decoded = jwt.verify(token, process.env.JWT_SECRET||process.env.JWT_SECRET|| "secret_key");

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

        const newToken = await UserService.generateToken(
        {
            _id: updatedUser._id,
            email: updatedUser.email,
            name: updatedUser.name,
            birthday: updatedUser.birthday || null,
        },
            process.env.JWT_SECRET || "secret_key",
            process.env.JWT_EXPIRE || "10h"
        );

        res.status(200).json({
            message: 'birthday added succesfully',
            token: newToken,
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
 exports.updateAccount= async (req,res,next)=>{
    try{
        const authHeader=req.headers.authorization;
        if(!authHeader){
            return res.status(401).json({message: 'No token'});
        }

        const token=authHeader.split(' ')[1];
        const decoded=jwt.verify(token, process.env.JWT_SECRET||"secret_key");

        const userId=decoded._id;
        if(!userId){
            return res.status(400).json({message:'User ID not found'});
        }

        const {name, email, birthday}=req.body;

        if(!name&&!email&&!birthday){
            return res.status(400).json({message:'Nothing to update'});
        }

        const updateData={};
        if(name) updateData.name=name;
        if(email) updateData.email=email;
        if(birthday) updateData.birthday=birthday;

        const updatedUser = await UserModel.findByIdAndUpdate(
            userId,
            updateData,
            {new: true, runValidators: true}
        );

        if(!updatedUser){
            return res.status(404).json({message: 'User not found'});
        }
        const newToken = await UserService.generateToken(
        {
            _id: updatedUser._id,
            email: updatedUser.email,
            name: updatedUser.name,
            birthday: updatedUser.birthday || null,
        },
            process.env.JWT_SECRET || "secret_key",
            process.env.JWT_EXPIRE || "10h"
        );

        res.status(200).json({
            status: true,
            message: "User updated succesfully",
            token: newToken,
            user: {
                name: updatedUser.name,
                email: updatedUser.email,
                birthday: updatedUser.birthday||null
            }
        });
    }catch(error){
        throw error;
    }
 }
exports.resetPassword = async (req,res,next)=>{
    try{
        const {name,email,newPassword}=req.body;

        if(!name||!email||!newPassword){
            return res.status(400).json({message: "Please provide name, email and password"})
        }

        const user = await UserModel.findOne({name,email});
        if(!user){
            return res.status(404).json({message: "User not found"});
        }

        user.password=newPassword;
        await user.save();

        const newToken = await UserService.generateToken(
            {
                _id: user._id,
                email: user.email,
                name: user.name,
                birthday: user.birthday||null,
            },
            process.env.JWT_SECRET||"secret_key",
            process.env.JWT_EXPIRE||"10h"
        );

        res.status(200).json({
            status: true,
            message: "Password reset succesfully",
            token: newToken,
            user:{
                name: user.name,
                email: user.email,
                birthday: user.birthday||null
            }
        });
    }catch(error){
        console.error(error);
        res.status(500).json({message: "Server error", error: error.message});
    }
}

exports.deleteAccount = async (req,res,next)=>{
    try{
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: "No token" });
        }

        const token = authHeader.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || "secret_key");

        const userId=decoded._id;
        if(!userId){
            return res.status(400).json({ message: "User ID not found" });
        }

        const deletedUser=await UserModel.findByIdAndDelete(userId);

        if(!deletedUser){
            return res.status(404).json({message:"User not found"});
        }

        return res.status(200).json({
            status: true,
            message: "Account deleted succesfully"
        });
    }catch(error){
        console.error(error);
        res.status(500).json({message: "Server error", error: error.message});
    }
}
