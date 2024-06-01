var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');
var mysql = require('mysql');
var { host, user, password, database } = require('./credentials.js');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcrypt');
const { sign, verify } = require('jsonwebtoken');
const credentials = require('./credentials.js');


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

const secretKey = credentials.secret
router.use(bodyParser.json());
router.post('/', function (req, res) {
    console.log('data received');
    const personaldata = req.body;
    const uniqueId = uuidv4();
    const query = 'INSERT INTO CLIENTS (ClientID, FirstName, SurName, LastName, Gender, BirthDate) VALUES (?,?,?,?,?,?)';
    const data = [
        uniqueId,
        personaldata.FirstName,
        personaldata.MiddleName,
        personaldata.SurName,
        personaldata.Gender,
        personaldata.BirthDate,

    ];
    try {
        db.query(query, data, (err) => {
            if (err) {
                console.error('Error Inserting Data into the Database:', err);
            } else {
                console.log('Data Inserted to Database');
                res.send(uniqueId);
            }
        })
    } catch (error) {
        console.error('Error parsing data');
        res.status(400).send('Internal Server Error');
    }
})

router.post('/RecruitmentInfo', function (req, res) {
    console.log(req.body);
    const formData = req.body;
    const data = [
        formData.Occupation,
        formData.License,
        formData.Institution,
        formData.City,
        formData.District,
        formData.Id
    ];
    const query = 'UPDATE CLIENTS SET OCCUPATION = ?, LICENSE = ?, INSTITUTION = ?, REGION = ?, District = ? WHERE ClientID = ?';
    try {
        db.query(query, data, (err) => {
            if (err) {
                console.error('Error Inserting data into the database:', err);
            } else {
                console.log('Data Inserted to Database');
                res.status(200).send('Data Successfully Inserted');
            }
        })
    } catch (error) {
        console.error('Error parsing data');
        res.status(400).send('Internal Server Error');
    }
})

router.post('/ContactInfo', function (req, res) {
    console.log(req.body);
    const formData = req.body;
    const data = [
        formData.Email,
        formData.Phone,
        formData.Id
    ];
    const query = 'UPDATE CLIENTS SET EMAIL = ?, PHONE = ? WHERE CLIENTID = ?';
    try {
        db.query(query, data, (err) => {
            if (err) {
                console.error('Error Inserting data into the database:', err);
            } else {
                console.log('Data Inserted to Database');
                res.status(200).send('Data Successfully Inserted');
            }
        })
    } catch (error) {
        console.error('Error parsing data');
        res.status(400).send('Internal Server Error');
    }
})

router.post('/AccountInfo', async function (req, res) {

    const formData = req.body;
    console.log(formData);
    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);
    const receivedPassword = formData.Password;
    const hashedPassword = await bcrypt.hash(receivedPassword, salt);
    const data = [
        formData.UserName,
        hashedPassword,
        formData.Id
    ];
    const query = 'UPDATE CLIENTS SET USERNAME = ?, PASSWORD = ? WHERE CLIENTID = ?';
    try {
        db.query(query, data, (err) => {
            if (err) {
                console.error('Error Inserting data into the database:', err);
            } else {
                console.log('Data Inserted to Database');
                try {
                    const id = formData.Id
                    console.log(id) //latest debug test
                    db.query('SELECT * FROM CLIENTS WHERE CLIENTID = ?', [id], async (err, results) => {
                        if (err) {
                            res.send('An error occured')
                        } else {
                            if (results.length > 0) {
                                const user = results[0]
                                console.log('User Credentials are:', user)
                                console.log('User Name is:', user.Username)
                                console.log('User id is:', user.ClientID)
                                const token = sign({ userId: user.ClientID, username: user.Username }, secretKey, { expiresIn: '30d' })
                                console.log(token)
                                res.json({ token })
                            } else {
                                res.status(400).send('Internal Server error')
                            }
                        }
                    })

                } catch (error) {
                    console.error('Error parsing data');
                    res.status(400).send('Internal Server Error');
                }
            }
        })
    } catch (error) {
        console.error('Error parsing data');
        res.status(400).send('Internal Server Error');
    }
})

const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1]
    console.log(token)
    if (!token) {
        return res.status(403).json({ error: 'Token not provided' })
    }

    verify(token, secretKey, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Invalid token' })
        }
        req.user = decoded
        next()
    })
}

router.post('/profile', verifyToken, (req, res) => {
    const userid = req.user.userId;
    console.log('Decoded Token:', req.user);
    db.query('SELECT * FROM CLIENTS WHERE CLIENTID = ?', [userid], (err, results) => {
        if (err) {
            console.error('Error fetching user data:', err);
            return res.status(500).json({ error: 'Internal Server Error' });
        }
        if (results.length == 0){
            console.log('User not found')
            return res.status(404).json({ error: 'User not found' });
        }
        const user = results[0]
        console.log(user)
        res.send(user)
    })
    console.log('Request Headers:', req.headers)
})


module.exports = router;