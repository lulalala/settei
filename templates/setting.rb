require 'settei/serializers/simple_serializer'
require 'settei/accessors/simple_accessor'
require 'settei/accessors/host_plugin'

serializer = Settei::Serializers::SimpleSerializer.new(
  file_dir_path: "#{File.dirname(__FILE__)}/environments"
)
Setting = Settei::Accessors::SimpleAccessor.new(
  config: serializer.load
)
Setting.extend Settei::Accessor::HostPlugin