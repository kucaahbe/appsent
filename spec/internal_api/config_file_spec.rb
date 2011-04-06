require 'spec_helper'

describe AppSent::ConfigFile do

  subject { described_class }

  before :each do
    @params = ['/path/to/config','config_name',:environment, Hash]
  end

  context ".new" do

    it "should raise exception if type is not hash and block given" do
      block = lambda {}
      @params[-1] = Array
      expect { subject.new(*@params,&block) }.to raise_exception(/params Array and block given/)
    end

  end

  context "#valid?" do

    context "should be true" do

      it "if config exists and environment presence(without type)(no values)" do
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return('environment' => {:a=>100500})
	subject.new(*@params).should be_valid
      end

      it "if config exists and environment presence(with type specified)(no values)" do
	@params[-1]=Array
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return(:environment => [1,2,3])
	subject.new(*@params).should be_valid
      end

      it "if config exists and environment presence(with values)" do
	values_block = lambda {
	  value :type => String
	}
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return('environment' => {:value=>'100500'})
	subject.new(*@params,&values_block).should be_valid
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
	@params[-1] = Array
	YAML.should_receive(:load_file).once.with('/path/to/config/config_name').and_return(:environment => 123)
      end

      after :each do
	subject.new(*@params).should_not be_valid
      end

    end

  end

end
