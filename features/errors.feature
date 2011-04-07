Feature: AppSent error messages
  As ruby developer
  In order to organize couple of config files
  I am using appsent

  Background:
    Given new rails application
    And I append to "config/application.rb" with:
    """
    AppSent.init :path => 'settings', :env => Rails.env.to_s do
    end
    """
    #And a file named "config/settings/system.yml" with:
    #"""
    #todo
    #"""
    #And a file named "config/settings/system.yml" with:
    #"""
    #todo
    #"""
    #And a file named "config/settings/system.yml" with:
    #"""
    #todo
    #"""

  Scenario: I see errors and fix them
    When I run `rails server`
    Then the output should contain:
    """
    todo
    """
