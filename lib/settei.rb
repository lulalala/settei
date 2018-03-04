require_relative "settei/version"
require_relative "settei/base"
require_relative "settei/loaders/simple_loader"
require_relative 'settei/railtie' if !!defined?(Rails)