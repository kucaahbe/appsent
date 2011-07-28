class AppSent
  class ConfigFile
    attr_reader :data

    CONFIG_NOT_FOUND_ERROR_MSG      = "missing config file '%s'"
    ENVIRONMENT_NOT_FOUND_ERROR_MSG = "config file '%s' has no '%s' environment"
    WRONG_CONFIG_ERROR_MSG          = "config file '%s' has missing or wrong type parameters:\n"

    def initialize config_dir, config_file_name, environment, type, &block
      @config_dir, @config_file_name, @environment, @type, @block = config_dir, config_file_name, (environment.to_sym rescue environment), type, block

      @type ||= Hash
      raise "params #{@type} and block given" if block_given? and not @type==Hash
      @path_to_config = File.join(@config_dir,@config_file_name+'.yml')
    end

    def valid?
      return @checked if defined?(@checked)

      yaml_data = YAML.load_file(@path_to_config)
      yaml_data.symbolize_keys!

      @data = yaml_data[@environment]

      @checked = if @data.instance_of?(@type)
		   @data.symbolize_keys! if @type==Hash
		   if @block
		     self.instance_exec(&@block)
		     @self_error_msg = WRONG_CONFIG_ERROR_MSG % relative_path_to_config
		     options.all? { |option| option.valid? }
		   else
		     true
		   end
		 else
		   false
		 end
    rescue NoMethodError, "undefined method `symbolize_keys!' for false:FalseClass"
      # yaml is not valid YAML file, TODO change error message
      @self_error_msg = ENVIRONMENT_NOT_FOUND_ERROR_MSG % [relative_path_to_config,@environment]
      @checked = false
    rescue Errno::ENOENT
      @self_error_msg = CONFIG_NOT_FOUND_ERROR_MSG % relative_path_to_config
      @checked = false
    end

    def options
      @options ||= []
    end

    def constantized
      @config_file_name.upcase
    end

    def error_message
      @self_error_msg += options.map { |o| o.error_message }.join("\n")
    end

    private

    def relative_path_to_config
      @path_to_config.gsub(Dir.pwd+File::SEPARATOR,'')
    end

    def method_missing option, opts={}, &block
      self.options << ConfigValue.new(option.to_s, opts[:type], @data[option.to_sym], opts[:desc], opts[:example], &block)
    end

  end
end
