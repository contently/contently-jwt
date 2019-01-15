require 'openssl'
require 'jwt'

module Contently
  module Jwt
    class Service
      attr_reader :private_key
      def initialize(key)
        @private_key = nil
        @private_key = if key.is_a? OpenSSL::PKey::RSA
                         key
                       else
                         OpenSSL::PKey::RSA.new File.read key
                       end
      end

      def public_key
        private_key.public_key
      end

      def encode(payload:)
        JWT.encode(payload, private_key, 'RS256')
      end

      def decode(token, verify = true)
        JWT.decode(token, public_key, verify, algorithm: 'RS256').first
      end
    end
  end
end
