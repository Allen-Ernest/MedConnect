const express = require('express');
var router = express.Router();
const mysql = require('mysql')
//const io = require('socket.io')(3000);
var bodyParser = require('body-parser');
const multer = require('multer')

const db = mysql.createConnection({
    host: host,
    user: user,
    password: password,
    database: database
});

db.connect(err => {
    if (err) {
        console.error('MySQL connection error:', err);
    } else {
        console.log('Connected to MySQL database');
    }
});

router.get('/uploadPost', (req, res)=>{ //Token verification
    const postInfo = req.body
    const uploader =  postInfo.uploader
    const query = 'INSERT INTO POSTS (Uploader, Image, Caption, Date)';
    const uploadDirectory = multer({dest: 'Media/Posts'})
    try {} catch (error) {}

})
router.get('/posts', (req, res) => {
    const query = 'SELECT * FROM POSTS';
    try {
        db.query(query, (err, result) => {
            if (err) {
                console.error('An error has occured in query')
                return res.status(500).json({ error: 'Internal Server Error' });
            } else if (results.length == 0) {
                return res.send('No Posts Available')
            } else {
                const posts = result;
                console.log(posts)
                res.status(200).send(posts)
            }
        })
    } catch (error) {
        console.error(error)
        res.status(400).send('Internal Server error')
    }
})

module.exports = router;