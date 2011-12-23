Feature: Complex usage

  Background:
    Given a file named "Conffile" with:
    """
    system_config do

      google_analytics do
        code              String, 'Enter your google analytics code here' => 'UA-12345678-1'
        multiple_domains  String, 'has multiple domains?'
        domain            String, 'your domain' => 'example.com'
      end

      system_email String, :example => 'admin@example.com'

    end

    mongodb do
      host       String, 'Host to connect to MongoDB' => 'localhost'
      port       Fixnum, 'MongoDB port' => 27017
      pool_size  Fixnum
      timeout    Fixnum
    end
    """
    And a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production'

    puts 'All stuff work!'
    """
      # TODO:
      #recaptcha :skip_env => true do
      #  recaptcha_public_key  String, 'Recaptcha public key'
      #  recaptcha_private_key String, 'Recaptcha private key'
      #end
      #notification_recipients Array, :skip_env => true, :each_value => TODO
      #
      #        slaves :type => Array do
      #          host String, 'mongo slave host' => 'host.com'
      #          port Fixnum, 'mongo slave port' => 27018
      #        end

  Scenario: All config present and have right values
    When I write to "config/system_config.yml" with:
    """
    production:
      google_analytics:
        code: UA-123456
        multiple_domains: 'false' # FIXME do something with boolean values
        domain: gopa.sraka.com
      system_email: admin@host.com
    """
    And I write to "config/mongodb.yml" following:
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
