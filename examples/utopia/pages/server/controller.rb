
prepend Actions

require 'async/websocket/server/rack'
require 'set'

$connections = Set.new

on 'connect' do |request|
	response = Async::WebSocket::Server::Rack.open(request.env) do |connection|
		$connections << connection
		
		while message = connection.read
			$connections.each do |connection|
				puts "Server sending message: #{message.inspect}"
				connection.write(message)
			end
		end
	ensure
		$connections.delete(connection)
	end
	
	Async.logger.info(self, request, response)
	
	respond?(response)
end
