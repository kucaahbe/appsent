@wip
Feature: Array with nested params

  Background:
    Given a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production' do

      mongodb do
        host      :type => String, :example => 'localhost', :desc => 'Host to connect to MongoDB'
        port      :type => Fixnum, :example => 27017,       :desc => 'MongoDB port'

        slaves :type => Array do
          host    :type => String, :example => 'host.com', :desc => 'mongo slave host'
          port    :type => Fixnum, :example => 27018,      :desc => 'mongo slave port'
        end
      end

    end

    puts 'All stuff work!'
    """

  Scenario: Nested array parameters do not specified
    When I write to "config/mongodb.yml" with:
    """
    production:
      host: example.com
      port: 27017
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/mongodb.yml':
      slaves:  # does not exist(Array)
    """

  Scenario: Array parameter wrong
    When I write to "config/mongodb.yml" with:
    """
    production:
      host: example.com
      port: 27017
      slaves: blabla
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/mongodb.yml':
      slaves: blabla # wrong type,should be Array
    """

  Scenario: Some of array parametres wrong
    When I write to "config/mongodb.yml" with:
    """
    production:
      host: example.com
      port: 27017
      slaves:
        - host: 100500
          port: 27018
        - host: sraka.com
          port: blabla
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/mongodb.yml':
      slaves:  # wrong nested array parameters
        - host: 100500 # wrong type,should be String(mongo slave host)
        - port: blabla # wrong type,should be Fixnum(mongo slave port)
    """

  Scenario: All right
    When I write to "config/mongodb.yml" with:
    """
    production:
      host: example.com
      port: 27017
      slaves:
        - host: host1.com
          port: 27018
        - host: host2.com
          port: 27018
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    All stuff work!
    """
