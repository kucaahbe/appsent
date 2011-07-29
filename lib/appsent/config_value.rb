class AppSent
  class ConfigValue
    attr_reader :parameter, :data_type, :data, :description, :example
    attr_accessor :nesting

    WRONG_DATA_TYPE_PASSED_MSG = "data type should be ruby class!"
    VALUE_NOT_EXISTS_MSG       = "does not exists"
    VALUE_WRONG_TYPE_MSG       = "wrong type,should be %s"
    FULL_ERROR_MESSAGE         = "%s: %s # %s%s%s"

    # data => it's an actual data of parameter
    def initialize parameter, data_type, data, description, example, &block
      @parameter, @data_type, @data, @description, @example = (parameter.to_sym rescue parameter), data_type, data, description, example

      @data_type ||= Hash
      raise WRONG_DATA_TYPE_PASSED_MSG unless @data_type.is_a?(Class)
      raise "params #{@data_type} and block given" if block_given? and not @data_type==Hash

      @block = block
      @nesting = 0
    end

    def valid?
      return @checked if defined?(@checked)
      @checked = if data.instance_of?(data_type)
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
      desc = (description and "(#{description})")
      actual_error_msg = (data ? VALUE_WRONG_TYPE_MSG % [data_type] : VALUE_NOT_EXISTS_MSG)
      optional_type = (data ? '' : ', '+data_type.inspect)
      '  '*(self.nesting+1)+FULL_ERROR_MESSAGE % [parameter, (data or example), actual_error_msg, desc, optional_type]
    end

    private

    def method_missing option, opts={}
      self.child_options << self.class.new(option.to_s, opts[:type], data[option.to_sym], opts[:desc], opts[:example])
      self.child_options.last.nesting+=(self.nesting+1)
    end
  end
end
