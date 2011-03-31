require 'spec_helper'

describe "AppSent.init" do

  before :each do
    @right_params = { :path => 'fixtures', :env => 'test' }
    @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__),'fixtures'))
  end

  it "should require config path" do
    @right_params.delete(:path)
    expect { AppSent.init(@right_params) do; end }.to raise_exception(AppSent::ConfigPathNotSet)
  end

  it "should require environment variable" do
    @right_params.delete(:env)
    expect { AppSent.init(@right_params) do; end }.to raise_exception(AppSent::EnvironmentNotSet)
  end

  it "should require block" do
    expect { AppSent.init(@right_params) }.to raise_exception(AppSent::BlockRequired)
  end

  it "should save config path to @@config_path" do
    AppSent.init(@right_params) do; end
    AppSent.config_path.should eq(@fixtures_path)
  end

  it "should save environment to @@environment" do
    AppSent.init(@right_params) do; end
    AppSent.class_variable_get(:@@environment).should eq('test')
  end

  it "should save array of configs to @@configs" do
    AppSent.init(@right_params) do
      config1
      config2
      config3
    end
    AppSent.config_files.should eq(%w(config1 config2 config3))
  end

end
