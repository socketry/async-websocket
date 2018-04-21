
var url = new URL('/server/connect', window.location.href);
url.protocol = url.protocol.replace('http', 'ws');

console.log("Connecting to server", url);
var server = new WebSocket(url.href);
console.log("Connected to", server);

server.onopen = function(event) {
	chat.onkeypress = function(event) {
		if (event.keyCode == 13) {
			server.send(JSON.stringify({text: chat.value}));
			
			chat.value = "";
		}
	}
};

server.onmessage = function(event) {
	console.log("Got message", event);
	
	var message = JSON.parse(event.data);
	
	var pre = document.createElement('pre');
	pre.innerText = message.text;
	
	response.appendChild(pre);
};
