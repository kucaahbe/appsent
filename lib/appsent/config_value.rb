class AppSent
  class ConfigValue
    attr_reader :parameter, :data_type, :data, :description, :example
    WRONG_DATA_TYPE_PASSED_MSG = "data type should be ruby class!"
    VALUE_NOT_EXISTS_MSG       = "does not exist"
    VALUE_WRONG_TYPE_MSG       = "wrong type,should be %s"

    def initialize parameter, data_type, data, description, example, &block
      @parameter, @data_type, @data, @description, @example = (parameter.to_sym rescue parameter), data_type, data, description, example

      @data_type ||= Hash
      raise WRONG_DATA_TYPE_PASSED_MSG unless @data_type.is_a?(Class)
      raise "params #{@data_type} and block given" if block_given? and not @data_type==Hash

      @block = block
    end

    def valid?
      if data.instance_of?(data_type)
	if @block
	  data.symbolize_keys!
	  self.instance_exec(&@block)
	  child_options.any? { |option| option.valid? }
	else
	  true
	end
      else
	false
      end
    end

    def child_options
      @options ||= []
    end

    def error_message
      msg  = parameter.to_s
      msg += "(#{description})" if description
      msg += ' => '
      msg += (data ? VALUE_WRONG_TYPE_MSG % [data_type] : VALUE_NOT_EXISTS_MSG)
      msg += "(example::  #{parameter}: #{example})" if example
    end

    private

    def method_missing option, opts={}
      self.child_options << self.class.new(option.to_s, opts[:type], data[option.to_sym], opts[:desc], opts[:example])
    end
  end
end
