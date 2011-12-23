Feature: Simple usage example

  Background:
    Given a file named "Conffile" with:
    """
    mongodb do
      host  String, 'Host to connect to MongoDB' => 'localhost'
      port  Fixnum, 'MongoDB port'               => 27017
    end
    """
    And a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production'

    puts 'All stuff work!'
    """
  Scenario: config does not exist
    When I run `ruby my_app.rb`
    Then the output should contain:
    """
    missing config file 'config/mongodb.yml'
    """

  Scenario: Config has no environment
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
      host: localhost # does not exist(Host to connect to MongoDB), String
      port: 27017 # does not exist(MongoDB port), Fixnum
    """

  Scenario: Some parameter is wrong type
    When I write to "config/mongodb.yml" following:
    """
    production:
      host: 100500
      port: 27017
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
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    All stuff work!
    """
