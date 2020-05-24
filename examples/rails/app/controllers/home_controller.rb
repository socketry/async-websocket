require 'async/websocket/adapters/rack'

class HomeController < ActionController::Metal
  def index
    response = Async::WebSocket::Adapters::Rack.open(request.env) do |connection|
      connection.write({message: "Hello World"})
    end
    
    self.set_response!(response)
    
    body.each -> chunks
    if body.respond_to?(:call)
      body.call(stream) # new interface
    
    
    
  end
end



class MyCrappyMiddleware
  def initialize(app)
    @app = app
  end
  
  def call(env)
    return self.dup
  end
  
  def finished(env, response, error = nil)
  end
end
