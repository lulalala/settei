require 'settei/loaders/simple_loader'
loader = Settei::Loaders::SimpleLoader.new(
  dir: File.join(File.dirname(__FILE__), "environments")
)
loader.load(fetch(:rails_env))

set :bundle_prefix, -> {
  %{#{loader.as_env_assignment} RAILS_ENV="#{fetch(:rails_env)}" #{fetch(:bundle_bin)} exec}
}