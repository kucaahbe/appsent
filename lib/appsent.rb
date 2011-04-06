require 'appsent/config_value'
require 'appsent/config_file'

class AppSent

  class ConfigPathNotSet  < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired     < StandardError; end

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
    settings.load! if settings.all_valid?
  end

  def self.config_files
    @@config_files
  end

  def self.config_path
    @@config_path
  end

  def all_valid?
    @@config_files.map { |config_file| ConfigFile.new(@@config_path,config_file,@@environment,Hash) }.any? { |conf_file| conf_file.valid? }
  end

  def load!
  end

  def method_missing method, *args, &block
    @@config_files << method.to_s
  end

end
