# Accessor for configuration values in a hash.
module Settei
  class Base
    extend Forwardable
    def_delegator :@config, :dig

    # @params config [Hash] configuration
    def initialize(config)
      self.config = config
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