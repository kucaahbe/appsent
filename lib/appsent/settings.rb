module AppSent
  class Settings
    attr_reader :config_path, :environment
    
    def initialize opts={}, &block
      raise ConfigPathNotSet  unless opts[:path]
      raise EnvironmentNotSet unless opts[:env]
      raise "caller path does not set" unless opts[:caller]
      raise BlockRequired     unless block_given?

      @config_path = File.expand_path(File.join(File.dirname(opts[:caller]),opts[:path]))
      @environment = opts[:env]

      @configs = []
      self.instance_exec(&block)
      if __valid__?
        __load__!
      else
        raise AppSent::Error, __full_error_message__
      end
    end

    private

    def __valid__?
      @configs.ask_all? { |conf_file| conf_file.valid? }
    end

    def __load__!
      @configs.each do |config|
        AppSent.const_set(config.constantized,config.data)
      end
    end

    def __full_error_message__
      error_description = ''
      @configs.each do |config|
        error_description += config.send(:__error_message__)+"\n" unless config.valid?
      end
      "failed to load some configuration files\n\n"+error_description
    end

    private

    def method_missing config, *args, &block
      @configs << ConfigFile.new(@config_path, config.to_s, @environment, *args, &block)
    end
  end
end
