require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @session = req.cookies["_rails_lite_app"]
    @session = (@session.nil? ? {} : JSON.parse(@session))
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = { path: '/', value: @session.to_json }
    res.set_cookie('_rails_lite_app', cookie)
  end
end
