require 'forwardable'

# Accessor for configuration values in a hash.
module Settei
  class Base
    extend Forwardable
    def_delegators :@config, :dig, :merge!, :fetch, :has_key?, :include?, :key?, :member?, :to_hash, :to_h

    # @params config [Hash] configuration
    def initialize(config)
      self.config = config
    end

    def dig_and_wrap(*args)
      result = dig(*args)
      if result.is_a?(Hash)
        self.class.new(result)
      else
        result
      end
    end

    def merge(*args)
      new_hash = @config.merge(*args)
      self.class.new(new_hash)
    end

    private

    def config=(config)
      @config = config

      begin
        require "active_support/core_ext/hash/indifferent_access"
        @config = @config.with_indifferent_access
      rescue LoadError
      end
    end
  end
end