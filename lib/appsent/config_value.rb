class AppSent
  class ConfigValue
    attr_reader :parameter, :data_type, :data, :description, :example
    attr_accessor :nesting

    WRONG_DATA_TYPE_PASSED_MSG = "data type should be ruby class!"
    VALUE_NOT_EXISTS_MSG       = "does not exists"
    VALUE_WRONG_TYPE_MSG       = "wrong type,should be %s"
    FULL_ERROR_MESSAGE         = "%s: %s # %s%s%s"
    WRONG_CHILD_OPTIONS_MSG    = "wrong nested parameters"

    # data => it's an actual data of parameter
    def initialize parameter, data_type, data, description, example, &block
      @parameter, @data_type, @data, @description, @example = (parameter and parameter.to_sym), data_type, data, description, example

      @data_type ||= Hash
      raise WRONG_DATA_TYPE_PASSED_MSG unless @data_type.is_a?(Class)
      raise "params #{@data_type} and block given" if block_given? and not [Array,Hash].include?(@data_type)

      @block = block
      @nesting = 0
    end

    def valid?
      return @valid if defined?(@valid)

      @valid = if data.instance_of?(data_type)
                 if @block
                   if data.is_a?(Array)
                     data.each do |data|
                       child_options << self.class.new(
                         @parameter,
                         Hash,
                         data,
                         @description,
                         @example,
                         &@block
                       )
                     end
                   else
                     data.symbolize_keys!
                     self.instance_exec(&@block)
                   end

                   @child_options_valid = child_options.ask_all? { |option| option.valid? }
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

    def child_options_valid?
      return @child_options_valid if defined?(@child_options_valid)
      true
    end

    def error_message
      actual_data_or_example = ((data_type==Hash ? '' : data) or example)

      actual_error_msg = if child_options_valid?
                           (data ? VALUE_WRONG_TYPE_MSG % [data_type] : VALUE_NOT_EXISTS_MSG)
                         else
                           WRONG_CHILD_OPTIONS_MSG
                         end

      desc = (description and "(#{description})")

      optional_type = (data ? '' : ', '+data_type.inspect)

      '  '*(self.nesting+1)+FULL_ERROR_MESSAGE % [parameter, actual_data_or_example, actual_error_msg, desc, optional_type]
    end

    private

    def method_missing option, opts={}
      self.child_options << self.class.new(
	option.to_s,
	opts[:type],
	data[option.to_sym],
	opts[:desc],
	opts[:example]
      )
      self.child_options.last.nesting+=(self.nesting+1)
    end
  end
end
