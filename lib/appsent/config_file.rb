module AppSent
  class ConfigFile
    attr_reader :data

    CONFIG_NOT_FOUND_ERROR_MSG      = "missing config file '%s'"
    ENVIRONMENT_NOT_FOUND_ERROR_MSG = "config file '%s' has no '%s' environment"
    WRONG_CONFIG_ERROR_MSG          = "wrong config file '%s':\n"

    def initialize config_dir, config_file_name, environment, *opts, &block
      @config_dir, @config_file_name, @environment, @block = config_dir, config_file_name, (environment && environment.to_sym), block

      @type = opts.empty? ? Hash : opts.first
      @type = @type[:type] if @type.is_a?(Hash)
      raise "params #{@type} and block given" if block_given? and not @type==Hash
      @path_to_config = File.join(@config_dir,@config_file_name+'.yml')
      @self_error_msg = ''
    end

    def valid?
      return @valid if defined?(@valid)
      __validate__!
    end

    def constantized
      @config_file_name.upcase
    end

    private

    def __error_message__
      @self_error_msg += __options__.map { |o| o.valid? ? nil : o.send(:__error_message__) }.compact.join("\n")
    end

    def __options__
      @options ||= []
    end

    def __validate__!
      yaml_data = YAML.load_file(@path_to_config)
      if yaml_data.is_a?(Hash)
        yaml_data.symbolize_keys!
      else
        # yaml is not valid YAML file, TODO change error message
        @self_error_msg = ENVIRONMENT_NOT_FOUND_ERROR_MSG % [__relative_path_to_config__,@environment]
        return @valid = false
      end

      @data = yaml_data[@environment]

      @valid = if @data.instance_of?(@type)
                 @data.symbolize_keys! if @type==Hash
                 if @block
                   self.instance_exec(&@block)
                   @self_error_msg = WRONG_CONFIG_ERROR_MSG % __relative_path_to_config__
                   __options__.ask_all? { |option| option.valid? }
                 else
                   true
                 end
               else
                 @self_error_msg = (WRONG_CONFIG_ERROR_MSG % __relative_path_to_config__) + "  '#{@environment}' entry should contain #{@type}"
                 false
               end
    rescue Errno::ENOENT
      @self_error_msg = CONFIG_NOT_FOUND_ERROR_MSG % __relative_path_to_config__
      @valid = false
    end

    def __relative_path_to_config__
      @path_to_config.gsub(Dir.pwd+File::SEPARATOR,'')
    end

    def method_missing option, *args, &block
      __options__ << ConfigValue.new(option.to_s, @data[option.to_sym], *args, &block)
    end

  end
end
