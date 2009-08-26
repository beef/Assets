require 'flash_sesion_cookie_middleware'
require 'admin_area'
require 'has_assets'
require 'swfupload'
require 'geometry_crop'
require 'imagescience_crop'

config.to_prepare do
  # Rack middleware for fixing flash's issues with sessions
  # http://thewebfellas.com/blog/2008/12/22/flash-uploaders-rails-cookie-based-sessions-and-csrf-rack-middleware-to-the-rescue
  ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]
  # Add the asset management helpers
  Admin::BaseController.helper(Admin::AssetsHelper)
  ApplicationController.helper(AssetsHelper)
end
ActiveRecord::Base.send :include, Beef::Has::Assets

if defined?(RedCloth)
  require 'custom_redcloth_tags'
end

