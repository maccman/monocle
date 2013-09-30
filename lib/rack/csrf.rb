module Rack
  class CSRF
    class InvalidCSRFToken < StandardError
      def http_status
        406
      end
    end

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
      token(env)
      raise InvalidCSRFToken unless accepts? env
      app.call(env)
    end

    def csrf_token(env)
      session(env)[options[:key]] ||= random_string
    end

    protected

    def session?(env)
      env.include? options[:session_key]
    end

    def session(env)
      return env[options[:session_key]] if session? env
      fail "You need to set up a session middleware *before* #{self.class}"
    end

    def token(env)
      session(env)[options[:key]] ||= random_string
    end

    def accepts?(env)
      return true if safe? env
      env[options[:header]] == token(env)
    end

    def safe?(env)
      %w[GET HEAD OPTIONS TRACE].include? env['REQUEST_METHOD']
    end

    def random_string(secure = defined? SecureRandom)
      secure ? SecureRandom.hex(32) : "%032x" % rand(2**128-1)
    rescue NotImplementedError
      random_string false
    end
  end
end