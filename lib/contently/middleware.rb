require_relative 'service'
require_relative 'authenticated_request'
module Contently
  module Jwt
    class Middleware
      def initialize(app)
        puts 'JWTMiddleware Started'
        @app = app
        @service = Service.new(Contently::Jwt.config[:private_key_path])
      end

      def call(env)
        return gatekeeper(env) if should_handle?(env)

        passthrough env
      end

      protected

      # Callbacks
      def pre_complete(token_helper)
      end

      def should_handle?(env)
        ['.css', 'js'].each do |ext|
          if env['REQUEST_PATH'].include? ext
            puts 'Excluded Request ' + env['REQUEST_PATH']
            return false
          end
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
          request.pre
          env = pre_complete(env, request)
          status, headers, response = @app.call env
          request.post(status,
                       headers,
                       response)

        end
        [status, headers, response]
      end

      def passthrough(env)
        status, headers, response = @app.call env
        [status, headers, response]
      end

      def report(time_start, time_end, kind="request")
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
