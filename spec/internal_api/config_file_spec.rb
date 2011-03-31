require 'spec_helper'

describe AppSent::ConfigFile do

  subject { described_class }

  before :each do
    @params = ['/path/to/config','config_name',:environment]
  end

  context "#valid?" do

    context "should be true" do

      it "if config exists and environment presence(without type)" do
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return('environment' => {:a=>100500})
	subject.new(*@params).should be_valid
      end

      it "if config exists and environment presence(with type specified)" do
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return(:environment => [1,2,3])
	subject.new(*@params,Array).should be_valid
      end

    end

    context "should be false" do

      it "if config does not exists" do
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_raise(Errno::ENOENT)
      end

      it "if environment does not presence in config" do
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return('other_environment' => {:a=>100500})
      end

      it "if wrong type" do
	@params << Array
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return(:environment => 123)
      end

      after :each do
	subject.new(*@params).should_not be_valid
      end

    end

  end

end
