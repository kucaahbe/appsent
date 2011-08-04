Feature: Usage with nested params example

  Background:
    Given a file named "my_app.rb" with:
    """
    require 'appsent'

    AppSent.init :path => 'config', :env => 'production' do
      system_config do

        google_analytics do
          code              String, 'Enter your google analytics code here' => 'UA-12345678-1'
          multiple_domains  String, 'has multiple domains?'
          domain            String, 'your domain' => 'example.com'
        end

      end
    end

    puts 'All stuff work!'
    """

  Scenario: Nested parameters do not specified
    When I write to "config/system_config.yml" with:
    """
    production:
      blabla
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/system_config.yml':
      'production' entry should contain Hash
    """
    When I write to "config/system_config.yml" with:
    """
    production:
      blabla: blabla
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/system_config.yml':
      google_analytics:  # does not exists, Hash
    """

  Scenario: Nested parameters does not specified
    When I write to "config/system_config.yml" with:
    """
    production:
      google_analytics:
        blabla: blabla
        domain: example.com
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/system_config.yml':
      google_analytics:  # wrong nested parameters
        code: UA-12345678-1 # does not exists(Enter your google analytics code here), String
        multiple_domains:  # does not exists(has multiple domains?), String
    """

  Scenario: Some nested parameters are wrong type
    When I write to "config/system_config.yml" with:
    """
    production:
      google_analytics:
        code: 100500
        multiple_domains: false
        domain: gopa.sraka.com
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    wrong config file 'config/system_config.yml':
      google_analytics:  # wrong nested parameters
        code: 100500 # wrong type,should be String(Enter your google analytics code here)
    """

  Scenario: All right
    When I write to "config/system_config.yml" with:
    """
    production:
      google_analytics:
        code: ZZ-31234123
        multiple_domains: 'false'
        domain: gopa.sraka.com
    """
    And I run `ruby my_app.rb`
    Then the output should contain:
    """
    All stuff work!
    """
