
prepend Actions

require 'async/websocket/server'

$connections = []

on 'connect' do |request|
	Async::WebSocket::Server.open(request.env) do |connection|
		$connections << connection
		
		while message = connection.next_message
			$connections.each do |connection|
				puts "Server sending message: #{message.inspect}"
				connection.send_message(message)
			end
		end
	end
	
	succeed!
end
