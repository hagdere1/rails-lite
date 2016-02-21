require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise "double render error" if already_built_response?

    @res['Location'] = url
    @res.status = 302

    @already_built_response = true

    session.store_session(@res)

    nil
  end

  def render_content(content, content_type)
    raise "double render error" if already_built_response?

    @res['Content-Type'] = content_type
    @res.write(content)

    @already_built_response = true

    session.store_session(@res)

    nil
  end

  def render(template_name)
    f = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(f).result(binding)
    render_content(template, 'text/html')
  end

  def session
    @session ||= Session.new(@req)
  end

  def invoke_action(action_name)
    self.send(action_name)
    render(action_name) unless already_built_response?

    nil
  end
end
