const UserService = require('../services/user_services');
const jwt = require('jsonwebtoken');
const UserModel= require('../model/user_model')
const NovelModel=require('../model/novel_model')
const nodemailer = require("nodemailer");

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
            res.status(404)
            throw new Error("User doesn't exist");
        }
        const isMatch = await user.comparePasswords(password);

        if (!isMatch){
            res.status(403)
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

 exports.saveProgress = async (req,res)=>{
    try{
        const authHeader = req.headers.authorization;
        if(!authHeader) return res.status(401).json({message:'No token'});

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        const email = decoded.email;

        const { slug, sceneIndex, dialogueIndex } = req.body;

        const user = await UserModel.findOne({email});
        const novel = await NovelModel.findOne({slug});

        if(!user || !novel) return res.status(404).json({message:'Not found'});

        const existing = user.progress.find(p => p.novel.toString() === novel._id.toString());

        if(existing){
            existing.sceneIndex = sceneIndex;
            existing.dialogueIndex = dialogueIndex;
        }else{
            user.progress.push({
                novel: novel._id,
                sceneIndex,
                dialogueIndex
            });
        }

        await user.save();
        res.status(200).json({message:'Progress saved'});

    }catch(err){
        console.log(err);
        res.status(500).json({message:'Error saving progress'});
    }
};

exports.getProgress = async (req,res)=>{
    try{
        const authHeader = req.headers.authorization;
        if(!authHeader) return res.status(401).json({message:'No token'});

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        const email = decoded.email;
        const {slug} = req.params;

        const user = await UserModel.findOne({email});
        const novel = await NovelModel.findOne({slug});

        if(!user || !novel) return res.status(404).json({message:'Not found'});

        const progress = user.progress.find(p => p.novel.toString() === novel._id.toString());

        if(!progress){
            return res.status(200).json({
                sceneIndex:0,
                dialogueIndex:0
            });
        }

        res.status(200).json(progress);

    }catch(err){
        res.status(500).json({message:'Error getting progress'});
    }
};

 exports.changePassword = async (req,res)=>{
    try{
        const authHeader = req.headers.authorization;
        const token = authHeader.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || "secret_key");

        const user = await UserModel.findById(decoded._id);
        if(!user){
            return res.status(404).json({message:"User not found"});
        }

        const {oldPassword, newPassword} = req.body;

        if(!oldPassword || !newPassword){
            return res.status(400).json({message:"Provide old and new password"});
        }

        const isMatch = await user.comparePasswords(oldPassword);

        if(!isMatch){
            return res.status(400).json({message:"Old password is incorrect"});
        }

        user.password = newPassword;
        await user.save();

        return res.status(200).json({
            status:true,
            message:"Password changed successfully"
        });

    }catch(e){
        res.status(500).json({message:"Server error"});
    }
}
exports.sendResetCode = async (req,res)=>{
    try{
        const {email} = req.body;

        const user = await UserModel.findOne({email});
        if(!user){
            return res.status(404).json({message:"User not found"});
        }

        const code = Math.floor(100000 + Math.random()*900000).toString();

        user.resetCode = code;
        user.resetCodeExpire = Date.now() + 10 * 60 * 1000; 
        await user.save();

        const transporter = nodemailer.createTransport({
            service:"gmail",
            auth:{
                user:process.env.EMAIL_USER ||"mc.dindon1898@gmail.com",
                pass:process.env.EMAIL_PASS || "ngcrilehifmcraol"
            }
        });

        await transporter.sendMail({
            from:process.env.EMAIL_USER,
            to:email,
            subject:"Password reset code",
            text:`Your reset code is: ${code}`
        });

        res.status(200).json({
            status:true,
            message:"Reset code sent"
        });

    }catch(e){
        res.status(500).json({message:"Email error"});
    }
}
exports.verifyResetCode = async (req,res)=>{
    try{
        const {email, code, newPassword} = req.body;

        const user = await UserModel.findOne({email});

        if(!user){
            return res.status(404).json({message:"User not found"});
        }

        if(user.resetCode !== code){
            return res.status(400).json({message:"Қате немесе ескі код"});
        }

        if(Date.now() > user.resetCodeExpire){
            return res.status(400).json({message:"Code expired"});
        }

        user.password = newPassword;
        user.resetCode = null;
        user.resetCodeExpire = null;

        await user.save();

        res.status(200).json({
            status:true,
            message:"Password reset successful"
        });

    }catch(e){
        res.status(500).json({message:"Server error"});
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
