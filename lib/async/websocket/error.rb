# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'protocol/websocket/error'

module Async
	module WebSocket
		class ProtocolError < ::Protocol::WebSocket::ProtocolError
		end
	end
end
