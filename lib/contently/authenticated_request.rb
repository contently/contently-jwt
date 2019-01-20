require_relative 'cookies_helper'
require_relative 'token_helper'

class AuthenticatedRequest
  attr_accessor :env, :token_processor

  def initialize(env, app)
    @token_refreshed = false
    @new_token = nil
    @env = env
    @app = app
    @cookies_helper = Contently::Jwt::CookiesHelper.new(env)
    @token_processor = Contently::Jwt::TokenHelper.new(@cookies_helper)
  end

  def authenticated?
    @token_processor.valid? || false
  end

  def request_uri
    @env['REQUEST_URI']
  end

  def perform_request(uri, req)
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      yield(http, req)
    end
  end

  def handle_expiriation(token)
    return token unless @token_processor.expired?

    if @token_processor.can_refresh?
      @token_processor.refresh
    end
  end

  def pre_process
    decoded_token = @token_processor.decode_token
    return nil if decoded_token.nil?

    handle_expiriation decoded_token
  end

  def safe_preprocess
    pre_process
  rescue JWT::DecodeError => err
    puts "Token invalid: #{err}"
  end

  def pre
    new_token = safe_preprocess
  end

  def new_token=(value)
    @new_token = value
  end

  def post(status, headers, response)
    return [status, headers, response] if @new_token.nil?

    response = Rack::Response.new response, status, headers
    exp = (Time.now.utc + 24 * 60 * 60).strftime('%a, %d %b %Y %H:%M:%S GMT')
    headers['Set-Cookie'] = "token=#{@new_token}; expires=#{exp}"
    [status, headers, response]
  end
end
