
prepend Actions

on 'list' do |request|
	Async.logger.info "Incoming request #{request.inspect}"
	
	if Async::WebSocket?(request.env)
		Async::WebSocket.open(request.env) do |connection|
			read, write = IO.pipe
			
			Process.spawn("ls -lah", :out => write)
			write.close
			
			read.each_line do |line|
				connection.text(line)
			end
			
			connection.close
		end
		
		succeed!
	end
end
