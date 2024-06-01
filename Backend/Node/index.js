var express = require('express');
const http = require('http');
var app = express();
var register = require('./registerUser.js');
var login = require('./login.js')

const server = http.createServer(app);


app.get('/', function (req, res) {
    console.log(req.body);
    res.status(200).send('Connection Succeeded');
})

app.use('/registerUser', register)
app.use('/login', login)

server.listen(9000, () => {
    console.log('Server is running on port 9000');
});

const io = require('socket.io')(server)
const users = {};
io.on('connection', (socket) => {
    const userId = socket.handshake.query.userId;
    users[userId] = socket.id;

    console.log(`User connected: ${userId} with socket ID: ${socket.id}`);
    socket.on('disconnect', () => {
        console.log('Disconnected', socket.id)
        delete users[userId];
    })
    socket.on('message', (data) => {
        const recipientSocketId = users[data.recipientId];
        if (recipientSocketId){
            io.to(recipientSocketId).emit('message-received', {
                message: data.message,
                senderId: data.senderId,
                recipientId: data.recipientId,
                timestamp: new Date().toISOString()
            })
            console.log(`Message from ${data.senderId} to ${data.recipientId}: ${data.message}`)
        } else {
            console.log(`Recipient ${data.recipientId} not connected`);
        }
        console.log(data)

        console.log(data.message)
    })
})