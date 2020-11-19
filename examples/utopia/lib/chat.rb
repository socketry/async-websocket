
require 'async/redis'

require 'db/client'
require 'db/postgres'

require 'thread/local'

module Chat
	module Redis
		extend Thread::Local
		
		def self.local
			endpoint = Async::Redis.local_endpoint
			client = Async::Redis::Client.new(endpoint)
		end
	end
end
