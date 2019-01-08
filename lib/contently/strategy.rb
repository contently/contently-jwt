require 'warden'
require 'devise/strategies/authenticatable'
require_relative 'service'
require 'net/http'
require 'jwt'

module Contently
  module Jwt
    class Strategy < Devise::Strategies::Authenticatable

      def initialize(*args)
        super(*args)
        @service = Service.new(Contently::Jwt.config[:private_key_path])
        puts "Contently JWT Strategy Initialized"
      end

      def valid?
        request.headers['Authorization'].present? || request.cookies['token'].present?
      end

      def find(idOrUsername)
        user = nil
        begin
          user = User.find(idOrUsername)
        rescue StandardError => exception
          user = User.find_by(:email =>idOrUsername)
        end
        user
      end

      def authenticate!
        puts "AUTHENTICATE"
        payload = @service.decode(token)
        success! find(payload['sub'])
      rescue ::JWT::ExpiredSignature
        fail! 'Auth token has expired. Please login again'
      rescue ::JWT::DecodeError
        fail! 'Auth token is invalid'
      rescue StandardError => err
        puts err
        fail!
      rescue Exception => err
        puts err
        fail!
      end

      private
      def token
        token = nil
        if (request.headers['Authorization'].present?)
          token = request.headers.fetch('Authorization', '').split(' ').last
        else
          token = request.cookies['token']
        end
        puts "TOKEN #{token}"
        token
      end
    end
  end
end

Warden::Strategies.add(:contently_jwt, Contently::Jwt::Strategy)
