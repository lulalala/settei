require 'base64'
require 'yaml'
require 'zlib'

module Settei
  module Loaders
    class SimpleLoader
      def initialize(file_dir_path: nil, env_var_name: 'APP_CONFIG', environment: nil)
        @env_var_name = env_var_name

        if !ENV[env_var_name].nil?
          @yaml = Zlib::Inflate.inflate(
            Base64.strict_decode64(ENV[@env_var_name])
          )
        else
          if !environment.nil?
            env_specific_file_path = "#{file_dir_path}/#{environment}.yml"
            if File.exist?(env_specific_file_path)
              file_path = env_specific_file_path
            end
          end
          file_path ||= "#{file_dir_path}/default.yml"

          @yaml = open(file_path).read
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

      # @return [String] #to_env_var with assignment to `env_var_name`
      def to_env_var_assignment
        "#{@env_var_name}=#{to_env_var}"
      end
    end
  end
end