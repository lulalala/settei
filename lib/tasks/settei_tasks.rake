require 'rake'

namespace :settei do
  namespace :install do
    desc "Setup settei for Rails project"
    task :rails do
      require 'settei/generators/rails'
      Settei::Generators::Rails.new(app_path: Dir.pwd).run
    end
  end

  namespace :heroku do
    namespace :config do
      desc "Update environment variable on Heroku"
      task :set do
        require 'settei/loaders/simple_loader'
        dir = File.join(Dir.pwd, 'config', 'environments')
        loader = Settei::Loaders::SimpleLoader.new(dir: dir)
        loader.load(:production)

        sh %{
          heroku config:set #{loader.as_env_assignment} --app #{ENV['app']}
        }
      end
    end
  end
end