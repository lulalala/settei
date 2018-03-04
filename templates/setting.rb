require 'settei/loaders/simple_loader'
require 'settei/base'
require 'settei/extensions/host_url'

loader= Settei::Loaders::SimpleLoader.new(
  file_dir_path: File.join(File.dirname(__FILE__), "environments")
)
Setting = Settei::Base.new(loader.to_hash)
Setting.extend Settei::Extensions::HostUrl
