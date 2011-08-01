Feature: Complex usage

  Background:
    Given a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production' do
      system_config do

        google_analytics do
          code              :type => String, :example => 'UA-12345678-1', :desc => 'Enter your google analytics code here'
          multiple_domains  :type => String, :desc => 'has multiple domains?'
          domain            :type => String, :example => 'example.com', :desc => 'your domain'
        end

        system_email :type => String, :example => 'admin@example.com'

      end

      mongodb do
        host      :type => String, :example => 'localhost', :desc => 'Host to connect to MongoDB'
        port      :type => Fixnum, :example => 27017,       :desc => 'MongoDB port'
        pool_size :type => Fixnum
        timeout   :type => Fixnum
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
      #
      #        slaves :type => Array do
      #          host    :type => String, :example => 'host.com', :desc => 'mongo slave host'
      #          port    :type => Fixnum, :example => 27018,      :desc => 'mongo slave port'
      #        end

    @wip @announce
  Scenario: All config present and have right values
    When I write to "config/system_config.yml" with:
    """
    production:
      google_analytics:
        code: 100500
        multiple_domains: false
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
