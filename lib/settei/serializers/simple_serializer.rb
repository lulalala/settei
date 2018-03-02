require 'base64'
require 'yaml'
require 'zlib'

# Try to load from ENV variable first, otherwise load from YAML files
module Settei
  module Serializers
    class SimpleSerializer
      def initialize(file_dir_path:, env_var_name: 'APP_CONFIG', environment: 'development')
        @env_var_name = env_var_name
        @file_path = "#{file_dir_path}/#{environment}.yml"
      end

      # @return [Hash]
      def load
        if !ENV[env_var_name].nil?
          yaml = Zlib::Inflate.inflate(
            Base64.strict_decode64(ENV[@env_var_name])
          )
        else
          yaml = open(@file_path).read
        end

        YAML.load(yaml)
      end

      # @return [String] config hash encoded as one environmental variable
      def dump
        yaml = open(@file_path).read
        Base64.strict_encode64(
          Zlib::Deflate.deflate(yaml)
        )
      end
    end
  end
end