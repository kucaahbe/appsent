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
    def initialize parameter, data, *opts, &block
      @parameter, @data = (parameter and parameter.to_sym), data

      if opts.size==1
        opts = opts.first
        begin
          %w( type desc example ).each do |deprecated_key|
            warn("AppSent DEPRECATION WARNING: :#{deprecated_key} is deprecated and will be removed in a future major release, go to online documentation and see how to define config values") if opts.has_key?(deprecated_key.to_sym)
          end

          @data_type, @description, @example = opts[:type], opts[:desc], opts[:example]
        rescue NoMethodError# opts is a [String]
          @data_type = opts
        end
      else
        @data_type = opts.delete_at(0)
        description_and_example = opts.delete_at(0)
        case description_and_example
        when String
          @description = description_and_example
        when Hash
          @description = description_and_example.keys.first
          @example = description_and_example.values.first
        end
      end

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

      @error_message = '  '*(self.nesting+1)+FULL_ERROR_MESSAGE % [parameter, actual_data_or_example, actual_error_msg, desc, optional_type]
      if child_options_valid?
        return @error_message
      else
        @error_message += "\n"+child_options.map { |o| o.valid? ? nil : o.error_message }.compact.join("\n")
      end
    end

    private

    def method_missing option, *opts, &block
      self.child_options << self.class.new(
        option.to_s,
        data[option.to_sym],
        *opts,
        &block
      )
      self.child_options.last.nesting+=(self.nesting+1)
    end
  end
end
