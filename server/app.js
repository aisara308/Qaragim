const express = require('express');
const body_parser = require('body-parser');
const cors = require('cors');
const userRoutes = require('./routers/routers')

const app = express();

app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}))

app.use(body_parser.json());

app.use('/',userRoutes);

module.exports=app;