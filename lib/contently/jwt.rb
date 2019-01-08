require "contently/jwt/version"
require "contently/service"
require "contently/middleware"
require "contently/strategy"
module Contently
  module Jwt
    class Error < StandardError; end
    # Your code goes here...
    @config = {
      :private_key_path => ''
    }

    @valid_config_keys = @config.keys

    def self.configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    def self.configure_with(path_to_yaml_file)
      begin
        config = YAML::load(IO.read(path_to_yaml_file))
      rescue Errno::ENOENT
        log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
      rescue Psych::SyntaxError
        log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
      end

      configure(config)
    end

    def self.config
      @config
    end
  end
end
