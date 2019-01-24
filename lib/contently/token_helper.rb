require_relative 'cookies_helper'
module Contently
  module Jwt
    class TokenHelper
      attr_accessor :env
      def initialize(cookies_helper, headers_helper, key = nil)
        @cookies_helper = cookies_helper
        @headers_helper = headers_helper
        @service = if key.nil?
                     Service.new(Contently::Jwt.config[:private_key_path])
                   else
                     Service.new(key)
                   end
      end

      def token
        @headers_helper.authorization_header_token ||
          @cookies_helper.cookies['token']
      end

      def perform_request(uri, req)
        Net::HTTP.start(uri.hostname, uri.port) do |http|
          yield(http, req)
        end
      end

      def refresh
        uri = auth_refresh_uri
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        refresh_token = decode_token['refreshToken']
        req.body = { refreshToken: refresh_token }.to_json
        perform_request(uri, req) do |http, request|
          resp = http.request request
          return process_refresh(resp)
        end
        nil
      end

      def decode_token(verify = true)
        return @service.decode(token, verify) unless token.nil?
      rescue JWT::DecodeError => err
        puts "Token could not be decoded: #{err}"
      end

      def exp_time
        decode_token(false)['exp'].to_i
      end

      def valid?
        decode_token && !expired?
      end

      def expired?
        Time.now.to_i > exp_time
      end

      def can_refresh?
        decoded = decode_token
        decoded && !decoded['refreshToken'].nil?
      end

      def auth_refresh_uri
        URI(ENV['AUTH_REFRESH'] || decode_token['refreshUrl'])
      end

      private

      def process_refresh(resp)
        if resp.code == '200'
          body = resp.read_body
          payload = JSON.parse(body)
          @cookies_helper['token'] = payload['token']
          @headers_helper.authorization_header_token = payload['token']
          return payload['token'] if payload['success']
        end
      end

    end
  end
end
