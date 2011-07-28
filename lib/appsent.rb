require 'appsent/tools'
require 'appsent/config_value'
require 'appsent/config_file'

class AppSent

  class ConfigPathNotSet  < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired     < StandardError; end
  class Error             < LoadError;     end

  @@config_path  = nil
  @@environment  = nil
  @@config_files = []

  def self.init opts={},&block
    raise ConfigPathNotSet  unless opts[:path]
    raise EnvironmentNotSet unless opts[:env]
    raise BlockRequired     unless block_given?

    caller_filename =  caller.first.split(':').first
    @@config_path = File.expand_path(File.join(File.dirname(caller_filename),opts[:path]))
    @@environment = opts[:env]

    settings = self.new
    settings.instance_exec(&block)
    if settings.all_valid?
      settings.load!
    else
      raise AppSent::Error, settings.full_error_message
    end
  end

  def self.config_files
    @@config_files
  end

  def self.config_path
    @@config_path
  end

  def initialize
    @configs=[]
  end

  def all_valid?
    @configs.all? { |conf_file| conf_file.valid? }
  end

  def load!
    @configs.each do |config|
      self.class.const_set(config.constantized,config.data)
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

  def method_missing config, args={}, &block
    config = config.to_s
    @@config_files << config
    @configs << ConfigFile.new(@@config_path,config,@@environment,args[:type],&block)
  end

end
