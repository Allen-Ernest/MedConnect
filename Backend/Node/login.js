const { sign, verify } = require('jsonwebtoken');
const { compare } = require('bcrypt');
const { json } = require('body-parser');
const { createConnection } = require('mysql');
const express = require('express');
const { host: _host, user: _user, password: _password, database: _database } = require('./credentials.js');
const credentials = require('./credentials.js');

const app = express()
app.use(json())

const db = createConnection({
    host: _host,
    user: _user,
    password: _password,
    database: _database
})

db.connect(err => {
    if (err) {
        console.error('MySQL connection error:', err)
    }
})

const secretKey = credentials.secret
app.post('/', (req, res) => {
    const username = req.body.username
    const password = req.body.password
    console.log(username + ' and password is ' + password)
    if (username && password) {
        db.query('SELECT * FROM CLIENTS WHERE USERNAME = ?', [username], async (err, results) => {
            if (err) {
                res.send('An error occured')
            } else {
                if (results.length > 0) {
                    const user = results[0]
                    const match = await compare(password, user['Password'])
                    if (match) {
                        const token = sign({ userId: user.ClientID, username: user.Username }, secretKey, { expiresIn: '30d' })
                        res.json({ token })
                    } else {
                        res.status(401).json({ error: 'Incorrect username or password' })
                    }
                } else {
                    res.status(401).json({ error: 'Incorrect username or password' })
                }
            }
        })
    } else {
        res.status(400).json({ error: 'Please provide username and password' })
    }
})

const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1]
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

module.exports = app