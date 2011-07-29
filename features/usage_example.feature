Feature: Usage example
  As ruby developer

  I want my application to start only when all config files exist and have right values

  and in this case I am using appsent

  Background:
    Given a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production' do
      mongodb do
        host      :type => String, :example => 'localhost', :desc => 'Host to connect to MongoDB'
        port      :type => Fixnum, :example => 27017,       :desc => 'MongoDB port'
        pool_size :type => Fixnum
        timeout   :type => Fixnum
      end
    end

    puts 'All stuff work!'
    """

  Scenario: config does not exists
    When I run `ruby my_app.rb`
    Then the output should contain:
    """
    missing config file 'config/mongodb.yml'
    """

  Scenario: Config has no environment(or config is wrong yml file(FIXME))
    When I add file named "config/mongodb.yml"
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    config file 'config/mongodb.yml' has no 'production' environment
    """

  Scenario: required parameteres do not specified
    When I write to "config/mongodb.yml" with:
    """
    production:
      optional_value: temp
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/mongodb.yml':
      host: localhost # does not exists(Host to connect to MongoDB), String
      port: 27017 # does not exists(MongoDB port), Fixnum
      pool_size:  # does not exists, Fixnum
      timeout:  # does not exists, Fixnum
    """

  Scenario: Some parameter is wrong
    When I write to "config/mongodb.yml" following:
    """
    production:
      host: 100500
      port: 27017
      pool_size: 1
      timeout: 5
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/mongodb.yml':
      host: 100500 # wrong type,should be String(Host to connect to MongoDB)
    """

  Scenario: All config present and have right values
    When I write to "config/mongodb.yml" following:
    """
    production:
      host: 'somehost.com'
      port: 27017
      pool_size: 1
      timeout: 5
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    All stuff work!
    """
