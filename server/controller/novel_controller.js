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

exports.getUserNovels = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ message: 'No token' });

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
    const email = decoded.email;

    const user = await UserModel.findOne({ email }).populate('userNovels');
    if (!user) return res.status(404).json({ message: 'User not found' });

    const novelsWithProgress = user.userNovels.map(novel => {
      const novelProgress = user.progress.find(p => p.novel.toString() === novel._id.toString());
      return {
        ...novel.toObject(),
        progress: novelProgress || { sceneIndex: 0, dialogueIndex: 0, finished: false }
      };
    });

    res.status(200).json(novelsWithProgress);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user novels', error: error.message });
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
exports.createNovel = async (req, res) => {
    try {
        const { title, description, tags, cover, slug, script } = req.body;

        if (!title || !description || !tags || !cover || !slug || !script) {
            return res.status(400).json({ message: 'Missing novel data' });
        }

        const existing = await NovelModel.findOne({ slug });
        if (existing) {
            return res.status(400).json({ message: 'Novel with this slug already exists' });
        }

        const novel = new NovelModel({
            title,
            description,
            tags,
            cover,
            slug,
            script
        });

        await novel.save();
        res.status(201).json({ message: 'Novel created successfully', novel });
    } catch (error) {
        res.status(500).json({ message: 'Error creating novel', error: error.message });
    }
};