require 'rack'
require_relative '../lib/controller_base'

class TestController < ControllerBase
  def go
    if @req.path == "/test"
      render_content("Test successful", "text/html")
    else
      redirect_to("/test")
    end
  end
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  TestController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
