require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'securerandom'

class ControllerBase
  attr_reader :req, :res, :params
  @@protect_from_forgery = false

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise 'Double render!'
    else
      @res['location'] = url
      @res.status = 302
      @already_built_response = true
      session.store_session(@res)
      @res.finish
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise 'Double render!'
    else
      @res.write(content)
      @res['Content-Type'] = content_type
      @already_built_response = true
      session.store_session(@res)
      @res.finish
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dirname = File.dirname(__FILE__)
    template_path = File.join(
      dirname,
      "..",
      "views",
      self.class.to_s.underscore,
      "#{template_name}.html.erb"
    )
    content = File.read(template_path)
    template = ERB.new(content).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    # debugger
    if protected? && @req.request_method != 'GET'
      check_authenticity_token
    end
    self.send(name)
    render(name) unless already_built_response?
  end

  # Token returned in response, user gets it as request
  # User has token in their cookies, attackers do not have it.

  # Imagine you're on malicious person's website and you click a link
  # Link directs you to your bank, you're logged in, and sends money to malicious person
  # With CSRF: third argument, token in params, included when served to user
  # Token sent to user in request, token in request must match token in params
  def form_authenticity_token
    @token ||= SecureRandom.urlsafe_base64(16)
    @res.set_cookie('authenticity_token', @token)
    @token
  end

  def check_authenticity_token
    token = @req.cookies['authenticity_token']
    raise 'Invalid authenticity token' unless token && token == params['authenticity_token']
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protected?
    @@protect_from_forgery
  end
end

