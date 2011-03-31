require 'spec_helper'

describe AppSent::ConfigValue do

  subject { described_class }

  before :each do
    @params = [ 'param_name', String, 'some string', 'description string', 'example string' ]
  end

  context ".new" do

    it "should raise exception if unsupported type passed" do
      expect { subject.new('parameter','asd','data') }.to raise_exception(/data type should be ruby class!/)
    end

  end

  context "#valid?" do

    context "should return false" do

      it "if entry does not presence in config file" do
	subject.new('paramname',String,nil).should_not be_valid
      end

      it "if data in config file has wrong type" do
	subject.new('paramname',String,2).should_not be_valid
      end

    end

    context "should return true" do

      it "if entry presence and has right type" do
	subject.new(*@params).should be_valid
      end

    end

  end

  context "#error_message" do

    it "should generate correct error message when no data" do
      subject.new('database',String,nil,'Database name','localhost').error_message.should eq("database(Database name) => does not exist(example::  database: localhost)")
    end

    it "should generate correct error message when type wrong" do
      subject.new('database',String,20,'Database name','localhost').error_message.should eq("database(Database name) => wrong type,should be String(example::  database: localhost)")
    end

  end
end
