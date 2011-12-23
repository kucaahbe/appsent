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
      if all_valid?
        load!
      else
        raise AppSent::Error, self.full_error_message
      end
    end

    def self.config_files
      @@config_files
    end

    def self.config_path
      @@config_path
    end

    def all_valid?
      @configs.ask_all? { |conf_file| conf_file.valid? }
    end

    def load!
      @configs.each do |config|
        AppSent.const_set(config.constantized,config.data)
      end
    end

    def full_error_message
      error_description = ''
      @configs.each do |config|
        error_description += config.error_message+"\n" unless config.valid?
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
