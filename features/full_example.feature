Feature: Complex usage

  Background:
    Given a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production' do
      system_config do

        google_analytics do
          code              :type => String, :example => 'UA-12345678-1', :desc => 'Enter your google analytics code here'
          multiple_domains  :type => Boolean, :desc => 'has multiple domains?'
          domain            :type => String, :example => 'example.com', :desc => 'your domain'
        end

        system_email :type => String, :example => 'admin@example.com'

      end

      mongodb do
        host      :type => String, :example => 'localhost', :desc => 'Host to connect to MongoDB'
        port      :type => Fixnum, :example => 27017,       :desc => 'MongoDB port'
        pool_size :type => Fixnum
        timeout   :type => Fixnum

        slaves :type => Array do
          host    :type => String, :example => 'host.com', :desc => 'mongo slave host'
          port    :type => Fixnum, :example => 27018,      :desc => 'mongo slave port'
        end
      end

    end

    puts 'All stuff work!'
    """
      # TODO:
      #recaptcha :skip_env => true do
      #  recaptcha_public_key  :type => String, :desc => 'Recaptcha public key'
      #  recaptcha_private_key :type => String, :desc => 'Recaptcha private key'
      #end
      #notification_recipients :type => Array, :skip_env => true, :each_value => TODO

  Scenario: config does not exists
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
