require 'lager'
require_relative 'cookies_helper'
require_relative 'headers_helper'
require_relative 'token_helper'
class AuthenticatedRequest
  extend Lager
  log_to $stdout, :debug
  attr_accessor :env, :token_processor

  def initialize(env, app)
    @lager = self.class.lager
    @token_refreshed = false
    @new_token = nil
    @env = env
    @app = app
    # TODO: introduce dependency injection here
    @cookies_helper = Contently::Jwt::CookiesHelper.new(env)
    @headers_helper = Contently::Jwt::HeadersHelper.new(env)
    @token_processor = Contently::Jwt::TokenHelper.new(@cookies_helper, @headers_helper)
  end

  def debug(str)
    @lager.debug("[authenticated-request]: #{str}")
  end

  def authenticated?
    @token_processor.valid? || false
  end

  def request_uri
    @env['REQUEST_URI']
  end

  def pre_process
    @token_processor.decode_token
  end

  def safe_preprocess
    pre_process
  rescue JWT::DecodeError => err
    puts "Token invalid: #{err}"
  end

  def pre
    safe_preprocess
  end

  def new_token=(value)
    raise 'Must be string' if value.is_a? Hash
    if value && value.include?('{')
      raise 'Bad Token Set--includes raw decoded token'
    end

    @new_token = value
  end

  def post(status, headers, response)
    return [status, headers, response] if @new_token.nil?

    # TODO: Do we need to use a path other than / ?
    headers['Set-Cookie'] =
      "token=#{@new_token}; path=/; expires=#{expiration_time}"
    [status, headers, response]
  end

  def expiration_time
    (Time.now.utc + 24 * 60 * 60).strftime('%a, %d %b %Y %H:%M:%S GMT')
  end
end
