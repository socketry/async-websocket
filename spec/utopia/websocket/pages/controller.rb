
on 'list' do |request|
	if Utopia::WebSocket?(request.env)
		Utopia::WebSocket.open(request.env) do |connection|
			read, write = IO.pipe
			
			Process.spawn("ls -lah", :out => write)
			write.close
			
			read.each_line do |line|
				connection.text(line)
			end
			
			connection.close
		end
		
		success!
	end
end
