
prepend Actions

require 'chat'
require 'async/websocket/adapters/rack'

on 'connect' do |request|
	channel = "chat.general"
	
	response = Async::WebSocket::Adapters::Rack.open(request.env) do |connection|
		client = Chat::Redis.instance
		
		subscription_task = Async do
			client.subscribe(channel) do |context|
				while true
					type, name, message = context.listen
					
					connection.write(JSON.parse(message))
					connection.flush
				end
			end
		end
		
		while message = connection.read
			client.publish(channel, JSON.dump(message))
		end
	ensure
		subscription_task&.stop
	end
	
	respond?(response)
end
