class AppSent
  class ConfigFile
    attr_reader :data

    def initialize config_dir, config_file_name, environment, type=Hash, &block
      @config_dir, @config_file_name, @environment = config_dir, config_file_name, (environment.to_sym rescue environment)
      if type.is_a?(Proc)
	@type = Hash
	@block = type
      else
	@type = type
	@block = block if block
      end
    end

    def valid?
      yaml_data = YAML.load_file(File.join(@config_dir,@config_file_name))

      if Hash.respond_to?(:symbolize_keys!)
	yaml_data.symbolize_keys!
      else
	yaml_data.keys.each { |key| yaml_data[(key.to_sym rescue key) || key] = yaml_data.delete(key) }
      end

      @data = yaml_data[@environment]
      if @data.instance_of?(@type)
	if @block
	  self.instance_exec(&@block)
	  options.any? { |option| option.valid? }
	else
	  true
	end
      else
	false
      end
    rescue Errno::ENOENT
      false
    end

    def options
      @options ||= []
    end

    def method_missing option, opts={}
      self.options << ConfigValue.new(option.to_s, opts[:type], @data[option.to_sym], opts[:desc], opts[:example])
    end
  end
end
