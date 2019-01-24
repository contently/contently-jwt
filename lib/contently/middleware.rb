require_relative 'service'
require_relative 'authenticated_request'
module Contently
  module Jwt
    class JwtError < StandardError; end
    class JwtConnectionError < JwtError; end
    class Middleware
      def initialize(app, options = {})
        puts 'Contently JWT Middleware Started'
        @app = app
        puts options
        @service = Service.new(options[:private_key_path] ||
          Contently::Jwt.config[:private_key_path])
      end

      def call(env)
        return gatekeeper(env) if should_handle?(env)

        passthrough env
      end

      protected

      # Callbacks
      def allow?(_env, _request)
        true
      end

      def should_handle?(env)
        ['.css', 'js'].each do |ext|
          return false if env['REQUEST_PATH'].include? ext
        end
        true
      end

      def time
        time_start = Time.now
        res = yield
        report(time_start, Time.now)
        res
      end

      def gatekeeper(env)
        status, headers, response = time do
          request = AuthenticatedRequest.new(env, @app)
          begin
            request.pre
            if allow?(env, request)

              status, headers, response = @app.call env
              request.post(status,
                           headers,
                           response)
            else
              ['401', { 'x-reason' => 'Access Denied' }, ['Not Authorized']]
            end
          rescue SocketError
            raise JwtConnectionError
          end
        end
        [status, headers, response]
      end

      def passthrough(env)
        status, headers, response = @app.call env
        [status, headers, response]
      end

      def report(time_start, time_end, kind = 'request')
        logstr = "#{kind} took #{(time_end - time_start) * 1000} ms"
        headerstr = ''
        (logstr.length + 4).times { headerstr << '=' }
        puts headerstr
        puts "+ #{logstr} +"
        puts headerstr
      end
    end
  end
end
