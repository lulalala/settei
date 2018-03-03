require 'settei/loaders/simple_loader'
require 'settei/accessors/simple_accessor'
require 'settei/accessors/host_plugin'

loader= Settei::Loaders::SimpleLoader.new(
  file_dir_path: File.join(File.dirname(__FILE__), "environments")
)
Setting = Settei::Accessors::SimpleAccessor.new(
  config: loader.to_hash
)
Setting.extend Settei::Accessor::HostPlugin
