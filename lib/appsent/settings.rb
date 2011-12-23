module AppSent
  class Settings

    @@config_path  = nil
    @@environment  = nil
    @@config_files = []

    def initialize opts={}, &block
      raise ConfigPathNotSet  unless opts[:path]
      raise EnvironmentNotSet unless opts[:env]
      raise "caller path does not set" unless opts[:caller]
      raise BlockRequired     unless block_given?

      @@config_path = File.expand_path(File.join(File.dirname(opts[:caller]),opts[:path]))
      @@environment = opts[:env]

      @configs=[]
      self.instance_exec(&block)
      if __valid__?
        __load__!
      else
        raise AppSent::Error, __full_error_message__
      end
    end

    def self.config_files
      @@config_files
    end

    def self.config_path
      @@config_path
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
      config = config.to_s
      @@config_files << config
      @configs << ConfigFile.new(@@config_path,config,@@environment,*args,&block)
    end
  end
end
