require_relative "connection"

module Async
	module WebSocket
		class Incoming < Connection
			def initialize(request)
				@env = build_env(request)
				@url = build_url(request)

				super hijacked_io(request), ::WebSocket::Driver.rack(self)
			end

			attr :env
			attr :url

			protected

			def build_env(request)
				{
					"HTTP_CONNECTION" => request.headers["connection"].to_s,
					"HTTP_HOST" => request.headers["host"].to_s,
					"HTTP_ORIGIN" => request.headers["origin"].to_s,
					"HTTP_SEC_WEBSOCKET_EXTENSIONS" => request.headers["sec-websocket-extensions"].to_s,
					"HTTP_SEC_WEBSOCKET_KEY" => request.headers["sec-websocket-key"].to_s,
					"HTTP_SEC_WEBSOCKET_KEY1" => request.headers["sec-websocket-key1"].to_s,
					"HTTP_SEC_WEBSOCKET_KEY2" => request.headers["sec-websocket-key2"].to_s,
					"HTTP_SEC_WEBSOCKET_PROTOCOL" => request.headers["sec-websocket-protocol"].to_s,
					"HTTP_SEC_WEBSOCKET_VERSION" => request.headers["sec-websocket-version"].to_s,
					"HTTP_UPGRADE" => request.headers["upgrade"].to_s,
					"REQUEST_METHOD" => request.method,
					"rack.input" => request.body
				}
			end

			def build_url(request)
				"#{request.scheme}://#{request.authority}#{request.path}"
			end

			def hijacked_io(request)
				wrapper = request.hijack
				io = Async::IO.try_convert(wrapper.io.dup)
				wrapper.close
				io
			end
		end
	end
end
