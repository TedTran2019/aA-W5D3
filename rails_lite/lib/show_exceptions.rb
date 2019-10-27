require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    @app.call(env)
  rescue StandardError => e
    render_exception(e)
  end

  private

  # If you use Rack::Response, statuses are automatically converted to
  # integers. And for some reason, the include doesn't work even if
  # it has the error name. I guess using an array it is.
  def render_exception(e)
    # res = Rack::Response.new
    # res.status = 500
    # res['Content-type'] = 'text/html'
    # res.body << e.class.to_s
    # res.finish
    ['500', {'Content-type' => 'text/html'}, [e.class.to_s]]
  end
end
