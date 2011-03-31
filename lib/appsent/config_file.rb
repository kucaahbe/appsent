class AppSent
  class ConfigFile
    attr_reader :data

    def initialize config_dir, config_file_name, environment, type=Hash
      @config_dir, @config_file_name, @environment, @type = config_dir, config_file_name, environment.to_s, type
    end

    def valid?
      yaml_data = YAML.load_file(File.join(@config_dir,@config_file_name))
      yaml_data.keys.each { |key| yaml_data[key.to_s] = yaml_data.delete(key) }

      @data = yaml_data[@environment]
      @data.instance_of?(@type)
    rescue Errno::ENOENT
      false
    end
  end
end
