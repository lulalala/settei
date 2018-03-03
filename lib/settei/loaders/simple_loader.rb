require 'base64'
require 'yaml'
require 'zlib'

module Settei
  module Loaders
    class SimpleLoader
      def initialize(file_dir_path:, env_var_name: 'APP_CONFIG', environment: 'development')
        @env_var_name = env_var_name
        @file_path = "#{file_dir_path}/#{environment}.yml"

        if !ENV[env_var_name].nil?
          @yaml = Zlib::Inflate.inflate(
            Base64.strict_decode64(ENV[@env_var_name])
          )
        else
          @yaml = open(@file_path).read
        end
      end

      # @return [Hash]
      def to_hash
        YAML.load(@yaml)
      end

      # @return [String] serialized config hash, for passing as environment variable
      def to_env_var
        Base64.strict_encode64(
          Zlib::Deflate.deflate(@yaml)
        )
      end
    end
  end
end