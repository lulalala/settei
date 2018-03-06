require 'forwardable'

# Accessor for configuration values in a hash.
module Settei
  class Base
    extend Forwardable
    # @!method dig(key, ...)
    #   @see Hash#dig
    # @!method merge(other_hash)
    #   @see Hash#merge
    # @!method fetch(key [, default])
    #   @see Hash#fetch
    # @!method has_key?(key)
    #   @see Hash#has_key?
    # @!method include?(key)
    #   @see Hash#include?
    # @!method key?(key)
    #   @see Hash#key?
    # @!method member?(key)
    #   @see Hash#member?
    # @!method to_hash
    # @!method to_h
    def_delegators :@config, :dig, :merge!, :fetch, :has_key?, :include?, :key?, :member?, :to_hash, :to_h

    # @param config [Hash] configuration
    def initialize(config)
      if !config.is_a? Hash
        raise ArgumentError.new('config is not a hash')
      end

      self.config = config
    end

    # Same as {#dig}, but will wrap return value as a {Settei::Base} if it is a hash.
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