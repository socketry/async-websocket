# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

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
					
					# The message is text, but contains JSON.
					connection.send_text(message)
					connection.flush
				end
			end
		end
		
		while message = connection.read
			client.publish(channel, message.buffer)
		end
	ensure
		subscription_task&.stop
	end
	
	respond?(response)
end
