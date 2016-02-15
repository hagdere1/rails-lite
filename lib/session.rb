require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie_hash = req.cookies['_rails_lite_app']
    if cookie_hash.nil?
      @cookie_hash = {}
    else
      @cookie_hash = JSON.parse(cookie_hash)
    end
  end

  def [](key)
    if @cookie_hash == {}
      nil
    else
      @cookie_hash[key]
    end
  end

  def []=(key, val)
    @cookie_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    @cookie_hash[:path] = "/"
    cookie_hash = @cookie_hash.to_json
    res.set_cookie('_rails_lite_app', cookie_hash)
  end
end
