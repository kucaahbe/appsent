require 'appsent/tools'
require 'appsent/config_value'
require 'appsent/config_file'
require 'appsent/settings'

module AppSent

  class ConfigPathNotSet  < ArgumentError; end
  class EnvironmentNotSet < ArgumentError; end
  class BlockRequired     < StandardError; end
  class Error             < LoadError;     end

end
