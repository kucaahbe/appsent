require 'aruba/cucumber'

Before('@wip') do
  @announce_stdout = true
  @announce_stderr = true
  @announce_cmd = true
  @announce_dir = true
  @announce_env = true
end
