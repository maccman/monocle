module Rack
  class SessionCSRF
    DEFAULT_OPTIONS = {
      :session_key => 'rack.session',
      :header      => 'HTTP_X_CSRF_TOKEN',
      :key         => 'csrf.token'
    }

    def self.csrf_token(env, options = {})
      self.new(options).csrf_token(env)
    end

    attr_reader :app, :options

    def initialize(app, options = {})
      @app, @options = app, DEFAULT_OPTIONS.merge(options)
    end

    def call(env)
      drop_session(env) unless accepts? env
      app.call(env)
    end

    def csrf_token(env)
      session(env)[options[:key]] ||= random_string
    end

    protected

    def accepts?(env)
      return true if safe? env
      token = session(env)[options[:key]] ||= random_string
      env[options[:header]] == token
    end

    def safe?(env)
      %w[GET HEAD OPTIONS TRACE].include? env['REQUEST_METHOD']
    end

    def session?(env)
      env.include? options[:session_key]
    end

    def session(env)
      return env[options[:session_key]] if session? env
      fail "You need to set up a session middleware *before* #{self.class}"
    end

    def drop_session(env)
      session(env).clear if session? env
    end

    def random_string(secure = defined? SecureRandom)
      secure ? SecureRandom.hex(32) : "%032x" % rand(2**128-1)
    rescue NotImplementedError
      random_string false
    end
  end
end