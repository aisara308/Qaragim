const NovelModel = require('../model/novel_model');
const UserModel = require('../model/user_model');
const User = require('../model/user_model');
const jwt = require('jsonwebtoken');

exports.getAllNovels = async (req, res)=>{
    try{
        const novels = await NovelModel.find();
        res.status(200).json(novels);
    }catch(err){
        res.status(500).json({message: "Cannot find novels", error : error.message});
    }
};

exports.addNovelToUser = async (req,res) =>{
    try{
        const authHeader = req.headers.authorization;
        if(!authHeader) return res.status(401).json({message: 'No token'});

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        const email = decoded.email;

        const {title, cover,  slug} = req.body;
        if(!title|| !cover|| !slug) return res.status(400).json({message: 'Missing novel data'});

        const user = await UserModel.findOne({email}).populate('userNovels');
        if (!user) return res.status(404).json({message: 'User not found'});

        let novel = await NovelModel.findOne({title});
        if(!novel){
            novel=new NovelModel({title,cover,folder,slug});
            await novel.save();
        }
        const alreadyAdded = user.userNovels.some(n=> n.title===title);
        if(alreadyAdded){
            return res.status(200).json({message: 'Novel already added'});
        }

        user.userNovels.push(novel._id);
        await user.save();

        res.status(200).json({message: 'Novel added succesfully'});
    }catch(error){
        res.status(500).json({message: 'Error adding model', error: error.message});
    }
};

exports.getUserNovels = async (req,res)=>{
    try{
        const authHeader = req.headers.authorization;
        if(!authHeader) return res.status(401).json({message: 'No token'});

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        const email = decoded.email;

        const user=await UserModel.findOne({email}).populate('userNovels');
        if(!user) return res.status(404).json({message: 'User not found'});

        res.status(200).json(user.userNovels);
    }catch(error){
        res.status(500).json({message: 'Error fetching user novels', error: error.message});
    }
};
exports.getNovelScript = async (req,res)=>{
    try{
        const {slug} = req.params;

        const novel = await NovelModel.findOne({slug});
        if(!novel) return res.status(404).json({message:"Novel not found"});

        res.status(200).json(novel.script);
    }catch(error){
        res.status(500).json({message:"Error fetching script", error:error.message});
    }
};