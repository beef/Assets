require 'has_assets/flash_sesion_cookie_middleware'
require 'has_assets/imagescience_crop'
require 'has_assets/geometry_crop'
require 'has_assets/swfupload'

config.to_prepare do
  # Rack middleware for fixing flash's issues with sessions
  # http://thewebfellas.com/blog/2008/12/22/flash-uploaders-rails-cookie-based-sessions-and-csrf-rack-middleware-to-the-rescue
  ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
  # Add the asset management helpers
  Admin::BaseController.helper(Admin::AssetsHelper)
  ApplicationController.helper(AssetsHelper)
end
ActiveRecord::Base.send :include, Beef::Has::Assets

if defined?(RedCloth)
  require 'has_assets/custom_redcloth_tags'
end

