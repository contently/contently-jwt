module Contently
  module Jwt
    class HeadersHelper
      attr_reader :env
      def initialize(env)
        @env = env
      end

      def authorization_header_token
        value = env['HTTP_AUTHORIZATION'] || 'Bearer'
        value.split('Bearer').map(&:strip)[1]
      end

      def authorization_header_token=(value)
        env['HTTP_AUTHORIZATION'] = "Bearer #{value}"
      end
    end
  end
end
