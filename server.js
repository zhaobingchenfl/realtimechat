var express = require('express');
var app = express();
app.use(express.static('public'));

var http = require("http").Server(app);
var io = require("socket.io")(http);

const port = process.env.PORT || 3000;


app.get("/", function(req, res) {
	res.sendFile(__dirname + "/index.html");
});

io.on("connection", function(socket) {

    socket.on("user_join", function(data) {
        this.username = data;
        socket.broadcast.emit("user_join", data);
    });

    socket.on("chat_message", function(data) {
        data.username = this.username;
        socket.broadcast.emit("chat_message", data);
    });

    socket.on("disconnect", function(data) {
        socket.broadcast.emit("user_leave", this.username);
	});
});

http.listen(port, function() {
	console.log("Listening on *:" + port);
});
