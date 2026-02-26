const UserService = require('../services/user_services');
const jwt = require('jsonwebtoken');
const UserModel= require('../model/user_model')

exports.register = async(req, res, next)=>{
    try{
        const {name,email,password}=req.body;

        const user = await UserService.registerUser(name,email,password);

        let tokenData = {_id: user._id, email: user.email, name: user.name, birthday: user.birthday||null}

        const token = await UserService.generateToken(tokenData,process.env.JWT_SECRET|| "secret_key",process.env.JWT_EXPIRE || "1h")

        const refreshToken = await UserService.generateToken(tokenData,process.env.JWT_SECRET|| "secret_key", "30d")

        res.status(200).json({status:true, token:token,refreshToken:refreshToken}) 
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

        let tokenData={_id:user._id, email: user.email, name: user.name, birthday: user.birthday||null, gender: user.gender||null}

        const token = await UserService.generateToken(tokenData, process.env.JWT_SECRET|| "secret_key", process.env.JWT_EXPIRE || "1h")

        const refreshToken = await UserService.generateToken(tokenData,process.env.JWT_SECRET|| "secret_key", "30d")

        res.status(200).json({status:true, token: token,refreshToken:refreshToken})
    }catch(error){
        throw error;
    }
}

exports.refreshToken=async(req,res)=>{
    try{
        const {refreshToken} = req.body;

        if(!refreshToken){
            return res.status(401).json({message:"No refresh token"})
        }

        const decoded=jwt.verify(
            refreshToken, 
            process.env.JWT_SECRET || "secret_key"
        )

        const user = await UserModel.findById(decoded._id);
        if(!user){
            return res.status(404).json({message:"User not found"});
        }

        const tokenData={
            _id:user._id,
            email:user.email,
            name:user.name,
            birthday:user.birthday||null,
            gender: user.gender||null
        };

        const newToken = await UserService.generateToken(tokenData,process.env.JWT_SECRET || "secret_key",
            process.env.JWT_EXPIRE || "1h");

        res.status(200).json({
            status:true,
            token:newToken
        });
    }catch(e){
        return res.status(401).json({
            message: "Invalid or expired refresh token"
        });   
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

        const {name, email, birthday, gender}=req.body;

        if(!name&&!email&&!birthday&&!gender){
            return res.status(400).json({message:'Nothing to update'});
        }

        const updateData={};
        if(name) updateData.name=name;
        if(email) updateData.email=email;
        if(birthday) updateData.birthday=birthday;
        if(gender) updateData.gender=gender;

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
            gender: updatedUser.gender||null
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
                birthday: updatedUser.birthday||null,
                gender: updatedUser.gender||null
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
