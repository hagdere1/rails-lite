class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (self.pattern =~ req.path) && (self.http_method.to_s == req.request_method.downcase)
  end

  def run(req, res)
    match_data = @pattern.match(req.path)
    names = match_data.names
    captures = match_data.captures

    route_params = Hash[names.zip(captures)]

    @controller_class.new(req, res, route_params).invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # return the route that matches this request
  def match(req)
    @routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    matching_route = match(req)
    if matching_route.nil?
      res.status = 404
    else
      matching_route.run(req, res)
    end
  end
end
