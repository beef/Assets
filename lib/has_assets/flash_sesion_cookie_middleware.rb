require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      params = ::Rack::Utils.parse_query(env['QUERY_STRING'])
      cookies = []
      params.each_pair do |key, value|
        if key =~ /^cookie/
          cookie_key = key[8..-2]
          cookies << [ cookie_key, value ].join('=').freeze
        end
      end
      env['HTTP_COOKIE'] = cookies.join(';')
    end
    @app.call(env)
  end
end