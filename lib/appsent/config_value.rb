class AppSent
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
end
