Feature: Workflow with APPSENT
  As ruby developer
  In order to organize couple of config files in my app
  I am using appsent

  Scenario: I see errors, fix them and run app!
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

    When I run `ruby my_app.rb`
    Then the output should match following appsent error:
    """
    missing config file '[a-z/]+/config/mongodb.yml'
    """

    When I add file named "config/mongodb.yml"
    And I run `ruby my_app.rb`
    Then the output should match following appsent error:
    """
    config file '[a-z/]+/config/mongodb.yml' has no 'production' environment
    """

    When I append to "config/mongodb.yml" with:
    """
    production:
      optional_value: temp
    """
    And I run `ruby my_app.rb`
    Then the output should match following appsent error:
    """
    config file '[a-z/]+/config/mongodb.yml' has missing or wrong type parameters:
      host: 'localhost'  # Host to connect to MongoDB (String)
      port: 27017  # MongoDB port (Fixnum)
      pool_size:   # (Fixnum)
      timeout:   # (Fixnum)
    """

    When I append to "config/mongodb.yml" with:
    """
      host: 100500
      port: 27017
      pool_size: 1
      timeout: 5
    """
    And I run `ruby my_app.rb`
    Then the output should match following appsent error:
    """
    config file '[a-z/]+/config/mongodb.yml' has missing (or wrong type) parameters:
      host(String, default: 'localhost'): Host to connect to MongoDB
    """

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
    All stuff work!
    """
