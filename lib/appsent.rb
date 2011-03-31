require 'appsent/config_value'
require 'appsent/config_file'

class AppSent

  class ConfigPathNotSet < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired < StandardError; end

  @@config_path  = nil
  @@environment  = nil
  @@config_files = []

  def self.init opts={},&block
    raise ConfigPathNotSet  unless opts[:path]
    raise EnvironmentNotSet unless opts[:env]
    raise BlockRequired     unless block_given?

    caller_filename =  caller.first[/^(.*):\d+:.*$/,1]
    @@config_path = File.expand_path(File.join(File.dirname(caller_filename),opts[:path]))
    @@environment = opts[:env]

    self.new.instance_exec(&block)
  end

  def self.config_files
    @@config_files
  end

  def self.config_path
    @@config_path
  end

  def method_missing method, &block
    @@config_files << method.to_s
  end

end
