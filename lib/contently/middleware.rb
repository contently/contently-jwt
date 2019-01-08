require_relative 'service'

module Contently
  module Jwt
    class Middleware
      def initialize(app)
        puts "JWTMiddleware Started"
        @app = app
        @service = Service.new(Contently::Jwt.config[:private_key_path])
      end

      def cookies(env)
        http_cookie = env['HTTP_COOKIE'] || ''
        cookies = http_cookie.split(';').select { |c| c.strip }
        Hash[cookies.collect { |v| [ v.split('=').first.strip, (v.split('=')[1]||'').strip ] }]
      end

      def cookies_out(cookies)
        cookies.map do |k,v| "#{k}=#{v}" end.join('; ')
      end

      def exp_time(token)
        token['exp'].to_i
      end

      def is_expired?(token)
        puts "#{Time.now.to_i} > #{exp_time(token)}"
        Time.now.to_i > exp_time(token)
      end

      def jwt_token(env)
        sent_cookies = cookies(env)
        if (sent_cookies['token'].present?)
          return @service.decode sent_cookies['token'], false
        end
        nil
      end

      def should?(env)
        ['.css','js'].each do |ext|
          if env['REQUEST_PATH'].include? ext
            puts "Excluded Request " + env['REQUEST_PATH']
            return false
          end
        end
        true
      end

      def can_refresh?(token)
        token['refreshToken'].present?
      end

      def do_refresh(token)
        puts "JWTMiddleware: do_refresh #{token}"
        auth_refresh = ENV['AUTH_REFRESH']
        uri = URI(auth_refresh);
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        refreshToken = token['refreshToken']
        req.body = { refreshToken: refreshToken }.to_json
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          resp = http.request(req).read_body
          payload = JSON.parse(resp)
          if payload['success']
            return payload['token']
          end
          return nil
        end
      end

      def call(env)
        time_start = Time.now
        new_token = nil
        if should? env
          begin
          token = jwt_token(env)
          if token && is_expired?(token)
            if can_refresh? token
              new_token = do_refresh(token)
              if new_token
                new_cookies = cookies(env)
                new_cookies['token'] = new_token;
                env['HTTP_COOKIE'] = cookies_out(new_cookies)
              end
            end
          end
          rescue Exception => err
            puts "Token invalid: #{err}"
          end
        end

        status, headers, response = @app.call(env)

        if new_token
          puts "Setting new token #{new_token}"
          response = Rack::Response.new response, status, headers
          exp = (Time.now.utc+24*60*60).strftime('%a, %d %b %Y %H:%M:%S GMT')
          puts exp
          headers["Set-Cookie"] = "token=#{new_token}; expires=#{exp}"
        end

        time_end = Time.now

        logstr = "request took #{(time_end-time_start)*1000} ms"
        headerstr = ""
        (logstr.length+4).times { headerstr << "=" }
        puts headerstr
        puts "+ #{logstr} +"
        puts headerstr

        [status, headers, response]
      end
    end
  end
end
