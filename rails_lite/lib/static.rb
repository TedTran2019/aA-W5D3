class Static
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    path = match?(req.fullpath)
    res = Rack::Response.new
    if path
      full_path = File.join(
        File.dirname(__FILE__),
        '..',
        path.to_s
      )
      content = grab_content(full_path)
      form_response(content, res)
    else
      res.status = 404
      res.write('Improper path!')
    end
    res.finish
  end

  private

  def match?(path)
    pattern = "^/public/[A-Za-z0-9/]+\.([0-9A-Za-z]+)$"
    Regexp.new(pattern).match(path)
  end

  def grab_content(full_path)
    File.read(full_path)
  rescue StandardError => e
    nil
  end

  def form_response(content, res)
    if content
      res.write(content)
    else
      res.status = 404
    end
  end
end
