require 'flash_sesion_cookie_middleware'
config.to_prepare do
  # Rack middleware for fixing flash's issues with sessions
  # http://thewebfellas.com/blog/2008/12/22/flash-uploaders-rails-cookie-based-sessions-and-csrf-rack-middleware-to-the-rescue
  ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]
end

require 'admin_area'
ActiveRecord::Base.send :include, Beef::Has::Assets

