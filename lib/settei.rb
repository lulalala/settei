require "settei/version"

module Settei
  def Base
    extend Forwardable
    def_delegator :@config, :dig

    def initialize(yaml)
      @yaml = yaml

      @config = YAML.load(@yaml)

      begin
        require "active_support/core_ext/hash/indifferent_access"
        @config = @config.with_indifferent_access
      rescue LoadError
      end
    end
  end
end
