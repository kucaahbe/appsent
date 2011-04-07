class AppSent
  class ConfigFile
    attr_reader :data

    def initialize config_dir, config_file_name, environment, type, &block
      @config_dir, @config_file_name, @environment, @type, @block = config_dir, config_file_name, (environment.to_sym rescue environment), type, block


      @type ||= Hash
      raise "params #{@type} and block given" if block_given? and not @type==Hash
    end

    def valid?
      yaml_data = YAML.load_file(File.join(@config_dir,@config_file_name+'.yml'))
      yaml_data.symbolize_keys!

      @data = yaml_data[@environment]


      if @data.instance_of?(@type)
	@data.symbolize_keys! if @type==Hash
	if @block
	  self.instance_exec(&@block)
	  options.all? { |option| option.valid? }
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

    def constantized
      @config_file_name.upcase
    end

    private

    def method_missing option, opts={}, &block
      self.options << ConfigValue.new(option.to_s, opts[:type], @data[option.to_sym], opts[:desc], opts[:example], &block)
    end
  end
end
