require 'rake'
require 'settei/generators/rails'

namespace :settei do
  namespace :install do
    desc "Setup settei for Rails project"
    task :rails do
      Settei::Generators::Rails.new(app_path: Dir.pwd).run
    end
  end
end