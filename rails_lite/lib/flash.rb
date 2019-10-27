require 'json'
require 'byebug'

# Old cookie info given to us -> dies here
# New cookie made -> lasts till next

class Flash
	def initialize(req)
		@cookies = req.cookies
		@old_flash = @cookies['_rails_lite_app_flash']
		@old_flash = JSON.parse(@old_flash) if @old_flash
		@flash = {}
		@flash_now = {}
	end

	def []=(key, val)
		@flash[key.to_s] = val
	end

	def store_flash(res)
		cookie = { path: '/', value: @flash.to_json }
		res.set_cookie('_rails_lite_app_flash', cookie)
	end

	def [](key)
		key = key.to_s
		return @flash[key] if @flash[key]
		return @flash_now[key] if @flash_now[key]
		return @old_flash[key] if @old_flash[key]
	end

	def now
		@flash_now
	end
end
