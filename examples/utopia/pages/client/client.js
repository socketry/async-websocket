
function connectToChatServer(url) {
	console.log("WebSocket Connecting...", url);
	var server = new WebSocket(url.href);
	
	server.onopen = function(event) {
		console.log("WebSocket Connected:", server);
		chat.disabled = false;
		
		chat.onkeypress = function(event) {
			if (event.keyCode == 13) {
				server.send(JSON.stringify({text: chat.value}));
				
				chat.value = "";
			}
		}
	};
	
	server.onmessage = function(event) {
		console.log("WebSocket Message:", event);
		
		var message = JSON.parse(event.data);
		
		var pre = document.createElement('pre');
		pre.innerText = message.text;
		
		response.appendChild(pre);
	};
	
	server.onerror = function(event) {
		console.log("WebSocket Error:", event);
		chat.disabled = true;
		server.close();
	};
	
	server.onclose = function(event) {
		console.log("WebSocket Close:", event);
		
		setTimeout(function() {
			connectToChatServer(url);
		}, 1000);
	};
}

var url = new URL('/server/connect', window.location.href);
url.protocol = url.protocol.replace('http', 'ws');

connectToChatServer(url);
