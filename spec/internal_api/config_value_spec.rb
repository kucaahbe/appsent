require 'spec_helper'

describe AppSent::ConfigValue do

  subject { described_class }

  before :each do
    @params = [ 'param_name', String, 'some string', 'description string', 'example string' ]
  end

  context ".new" do

    %w(valid? child_options error_message).each do |method|
      it { subject.new(*@params).should respond_to(method)}
    end

    it "should raise exception if unsupported type passed" do
      expect { subject.new('parameter','asd','data',nil,nil) }.to raise_exception(/data type should be ruby class!/)
    end

    it "should raise exception if type is not hash and block given" do
      block = lambda {}
      @params[1] = Array
      expect { subject.new(*@params,&block) }.to raise_exception(/params Array and block given/)
    end

  end

  context "#valid?" do

    context "should return false" do

      it "if entry does not presence in config file" do
	subject.new('paramname',String,nil,nil,nil).should_not be_valid
      end

      it "if data in config file has wrong type" do
	subject.new('paramname',String,2,nil,nil).should_not be_valid
      end

      it "if child value is not valid" do
	@params[1]=Hash
	@params[2]={:value => 100500}
	values_block = lambda {
	  value :type => String
	}
	subject.new(*@params,&values_block).should_not be_valid
      end

    end

    context "should return true" do

      it "if entry presence and has right type" do
	subject.new(*@params).should be_valid
      end

      it "if valid itself and shild values valid too" do
	@params[1]=Hash
	@params[2]={'value' => 'some data'}
	values_block = lambda {
	  value :type => String
	}
	subject.new(*@params,&values_block).should be_valid
      end

    end

  end

  context "#error_message" do

    context "should generate correct error message when no data" do

      it "with full description" do
	subject.new('database',String,nil,'Database name','localhost').error_message.should eq("  database: localhost # does not exists(Database name), String")
      end

      it "without example value" do
	subject.new('database',String,nil,'Database name',nil).error_message.should eq("  database:  # does not exists(Database name), String")
      end

      it "without description" do
	subject.new('database',String,nil,nil,'localhost').error_message.should eq("  database: localhost # does not exists, String")
      end

      it "without example and description" do
	subject.new('database',String,nil,nil,nil).error_message.should eq("  database:  # does not exists, String")
      end

    end

    context "should generate correct error message when no data is of wrong type" do

      it "with full description" do
	subject.new('database',String,20,'Database name','localhost').error_message.should eq("  database: 20 # wrong type,should be String(Database name)")
      end

      it "without example value" do
	subject.new('database',String,20,'Database name',nil).error_message.should eq("  database: 20 # wrong type,should be String(Database name)")
      end

      it "without description" do
	subject.new('database',String,20,nil,'localhost').error_message.should eq("  database: 20 # wrong type,should be String")
      end

      it "without example and description" do
	subject.new('database',String,20,nil,nil).error_message.should eq("  database: 20 # wrong type,should be String")
      end

    end

  end
end
