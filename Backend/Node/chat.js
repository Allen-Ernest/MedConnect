const socketIO = require('socket.io');

function initializeSocket(httpServer) {
    const io = socketIO(httpServer);
    console.log('Socket.IO server is running');
    io.on('connection', (socket) => {
        console.log('A user connected:', socket.id);
    });

    return io;
}

module.exports = initializeSocket;
