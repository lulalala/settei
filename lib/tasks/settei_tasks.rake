require 'rake'
require 'settei/generators/rails'

namespace :settei do
  namespace :rails do
    desc "Setup settei for Rails project"
    task :install do
      Settei::Generators::Rails.new(app_path: Dir.pwd).run
    end
  end
end