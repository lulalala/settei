require 'settei/loaders/simple_loader'
loader = Settei::Loaders::SimpleLoader.new(
  dir: File.join(File.dirname(__FILE__), "environments")
)
loader.load(fetch(:rails_env))

set :default_env, {loader.env_name => loader.as_env_value}