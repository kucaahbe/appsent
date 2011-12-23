require 'appsent/tools'
require 'appsent/config_value'
require 'appsent/config_file'
require 'appsent/settings'

module AppSent

  class ConfigPathNotSet  < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired     < StandardError; end
  class Error             < LoadError;     end

  def self.init appsent_config={}
    caller_path = caller.first.split(':').first
    conffile_path = File.expand_path( File.join('../Conffile'), caller_path )
    conffile_content = IO.read(conffile_path)
    block = lambda { eval conffile_content }
    Settings.new appsent_config.merge(:caller => caller_path), &block
  end

end
