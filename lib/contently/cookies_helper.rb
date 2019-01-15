module Contently
  module Jwt
    class CookiesHelper
      attr_reader :env
      def initialize(env)
        @env = env
      end

      def http_cookie
        env['HTTP_COOKIE'] || ''
      end

      def cookies
        cookies = http_cookie.split(';').select(&:strip)
        Hash[cookies.collect { |v| [v.split('=').first.strip, (v.split('=')[1] || '').strip] }]
      end

      def [](key)
        cookies[key]
      end

      def []=(key, value)
        puts "#{key} #{value}"
        cache = cookies
        cache[key] = value
        env['HTTP_COOKIE'] = make_cookie_header(cache)
      end

      def make_cookie_header(cookies)
        cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
      end
    end
  end
end
