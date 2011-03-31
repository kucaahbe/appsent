class AppSent
  class ConfigPathNotSet < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired < StandardError; end

  @@config_path  = nil
  @@environment  = nil
  @@config_files = []

  def self.init opts={},&block
    raise ConfigPathNotSet  unless opts[:path]
    raise EnvironmentNotSet unless opts[:env]
    raise BlockRequired     unless block_given?

    caller_filename =  caller.first[/^(.*):\d+:.*$/,1]
    @@config_path = File.expand_path(File.join(File.dirname(caller_filename),opts[:path]))
    @@environment = opts[:env]

    self.new.instance_exec(&block)
  end

  def self.config_files
    @@config_files
  end

  def self.config_path
    @@config_path
  end

  def method_missing method, &block
    @@config_files << method.to_s
  end

  class ConfigValue
    attr_reader :parameter, :data_type, :data, :description, :example
    WRONG_DATA_TYPE_PASSED_MSG = "data type should be ruby class!"
    VALUE_NOT_EXISTS_MSG       = "does not exist"
    VALUE_WRONG_TYPE_MSG       = "wrong type,should be %s"

    def initialize parameter, data_type, data, description=nil, example=nil
      @parameter, @data_type, @data, @description, @example = parameter, data_type, data, description, example
      raise WRONG_DATA_TYPE_PASSED_MSG unless data_type.is_a?(Class)
    end

    def valid?
      data.instance_of?(data_type)
    end

    def error_message
      msg  = parameter
      msg += "(#{description})" if description
      msg += ' => '
      msg += (data ? VALUE_WRONG_TYPE_MSG % [data_type] : VALUE_NOT_EXISTS_MSG)
      msg += "(example::  #{parameter}: #{example})" if example
    end
  end

  class ConfigFile < ConfigValue
  end
end
