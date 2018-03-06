module Settei
  module Generators
    class Rails
      def initialize(app_path:)
        @app_path = app_path

        spec = Gem::Specification.find_by_name("settei")
        @gem_path = spec.gem_dir
      end

      def run
        create_setting_rb
        create_ymls
        update_application_rb
        update_gitignore
        update_deploy_rb
      end

      private

      def create_setting_rb
        file_name = 'config/setting.rb'.freeze

        create_if_absent(file_name) do |file_name|
          FileUtils.cp(
            File.join(@gem_path, 'templates/setting.rb'),
            File.join(@app_path, file_name)
          )
        end
      end

      def create_ymls
        [:production, :default].each do |env|
          file_name = "config/environments/#{env}.yml"

          create_if_absent(file_name) do |file_name|
            FileUtils.cp(
              File.join(@gem_path, 'templates/setting.yml'),
              File.join(@app_path, file_name)
            )
          end
        end
      end

      def update_application_rb
        file_name = 'config/application.rb'
        file_path = File.join(@app_path, file_name)
        text = "require_relative 'setting'"

        file_content = File.read(file_path)
        return if file_content.include?(text)

        gsub_file(file_name, file_path, "require 'rails/all'", "require 'rails/all'\n\n#{text}")
      end

      def update_gitignore
        file_name = '.gitignore'
        file_path = File.join(@app_path, file_name)
        text = "\n/config/environments/*.yml"

        append(file_name, file_path, text)
      end

      def update_deploy_rb
        file_name = 'config/deploy.rb'
        file_path = File.join(@app_path, file_name)

        return if !File.exist?(file_path)

        file_content = File.read(file_path)
        return if file_content.include?('Settei::')

        if defined?(Mina)
          text = File.read(File.join(@gem_path, 'templates/_mina.rb'))
        elsif defined?(Capistrano)
          text = File.read(File.join(@gem_path, 'templates/_capistrano.rb'))
        else
          return
        end

        text.prepend("\n\n# Settei: append serialized config as an environment variable\n")

        append(file_name, file_path, text)
      end

      def append(file_name, file_path, text)
        file_content = File.read(file_path)
        if !file_content.include?(text)
          File.open(file_path, 'a+') { |file| file.write(text) }
          puts "Appended: #{file_name}"
        end
      end

      def create_if_absent(file_name)
        if File.exist?(file_name)
          puts "Already exists: #{file_name}, skipped"
        else
          yield file_name
          puts "Created: #{file_name}"
        end
      end

      # Copied and modified from thor
      def gsub_file(file_name, file_path, flag, *args, &block)
        content = File.read(file_path)
        content.gsub!(flag, *args, &block)
        File.open(file_path, "wb") { |file| file.write(content) }

        puts "Inserted: #{file_name}"
      end
    end
  end
end