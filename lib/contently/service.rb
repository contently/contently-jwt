require 'openssl'
require 'jwt'

module Contently
  module Jwt
    class Service
      def initialize(privateKeyPath)
        @privateKeyPath = privateKeyPath
      end

      def private_key
        OpenSSL::PKey::RSA.new File.read(@privateKeyPath);
      end

      def public_key
        self.private_key.public_key
      end

      def encode(payload:)
        JWT.encode(payload, private_key, 'RS256')
      end

      def decode(token, verify = true)
        JWT.decode(token, self.public_key, verify, { algorithm: 'RS256'}).first
      end
    end
  end
end
