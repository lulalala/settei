require 'settei/loaders/simple_loader'
require 'settei/base'
require 'settei/extensions/host_url'

if defined? Rails
  rails_env = Rails.env
end

loader= Settei::Loaders::SimpleLoader.new(
  dir: File.join(File.dirname(__FILE__), "environments")
)
Setting = Settei::Base.new(loader.load(rails_env).as_hash)
Setting.extend Settei::Extensions::HostUrl
