module AppSent
  class ConfigValue
    attr_reader :parameter, :data_type, :data, :description, :example
    attr_accessor :nesting

    WRONG_DATA_TYPE_PASSED_MSG = "data type should be ruby class!"
    VALUE_NOT_EXISTS_MSG       = "does not exist"
    VALUE_WRONG_TYPE_MSG       = "wrong type,should be %s"
    FULL_ERROR_MESSAGE         = "%s: %s # %s%s%s"
    WRONG_CHILD_OPTIONS_MSG    = "wrong nested parameters"

    # data => it's an actual data of parameter
    def initialize parameter, data, *opts, &block
      @parameter, @data = (parameter and parameter.to_sym), data

      @data_type = opts.delete_at(0)

      description_and_example = opts.delete_at(0)
      case description_and_example
      when String
        @description = description_and_example
      when Hash
        @description = description_and_example.keys.first
        @example = description_and_example.values.first
      end

      @data_type ||= Hash
      raise WRONG_DATA_TYPE_PASSED_MSG unless @data_type.is_a?(Class)
      raise "params #{@data_type} and block given" if block_given? and not [Array,Hash].include?(@data_type)

      @block = block
      @nesting = 0
    end

    def valid?
      return @valid if defined?(@valid)
      __validate__!
    end

    private

    def __child_options__
      @options ||= []
    end

    def __child_options_valid__?
      return @child_options_valid if defined?(@child_options_valid)
      true
    end

    def __error_message__
      actual_data_or_example = ((data_type==Hash ? '' : data) or example)

      actual_error_msg = if __child_options_valid__?
                           (data ? VALUE_WRONG_TYPE_MSG % [data_type] : VALUE_NOT_EXISTS_MSG)
                         else
                           WRONG_CHILD_OPTIONS_MSG
                         end

      desc = (description and "(#{description})")

      optional_type = (data ? '' : ', '+data_type.inspect)

      @error_message = '  '*(self.nesting+1)+FULL_ERROR_MESSAGE % [parameter, actual_data_or_example, actual_error_msg, desc, optional_type]
      if __child_options_valid__?
        return @error_message
      else
        @error_message += "\n"+__child_options__.map { |o| o.valid? ? nil : o.send(:__error_message__) }.compact.join("\n")
      end
    end

    def __validate__!
      @valid = if data.instance_of?(data_type)
                 if @block
                   if data.is_a?(Array)
                     data.each do |data|
                       __child_options__ << self.class.new(
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

                   @child_options_valid = __child_options__.ask_all? { |option| option.valid? }
                 else
                   true
                 end
               else
                 false
               end
    end

    def method_missing option, *opts, &block
      __child_options__ << self.class.new(
        option.to_s,
        data[option.to_sym],
        *opts,
        &block
      )
      __child_options__.last.nesting+=(self.nesting+1)
    end
  end
end
