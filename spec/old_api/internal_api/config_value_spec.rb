require 'spec_helper'

describe AppSent::ConfigValue do

  subject { described_class }

  before :each do
    @params = {
      'name'    => 'param_name',
      'type'    =>  String,
      'value'   => 'some string',
      'desc'    => 'description string',
      'example' => 'example'
    }
  end

  let(:params) do
    [
      @params['name'],
      @params['value'],
      {
      :type => @params['type'],
      :desc =>  @params['desc'],
      :example => @params['example']
    }
    ]
  end

  context ".new" do

    %w(valid? child_options error_message).each do |method|
      it { subject.new(*params).should respond_to(method)}
    end

    it "should raise exception if unsupported type passed" do
      @params['type'] = 'asd'
      expect { subject.new(*params) }.to raise_exception(/data type should be ruby class!/)
    end

    context "with &block given" do

      let(:block) do
	lambda { value :type => String }
      end

      it "should not raise exception if data type is Array" do
	@params['type'] = Array
	expect { subject.new(*params,&block) }.to_not raise_exception(/params Array and block given/)
      end

      it "should not raise exception if data type is Hash" do
	@params['type'] = Hash
	expect { subject.new(*params,&block) }.to_not raise_exception(/params Hash and block given/)
      end

      it "should raise exception if data type is not Hash" do
	@params['type'] = Fixnum
	expect { subject.new(*params,&block) }.to raise_exception(/params Fixnum and block given/)
      end

    end

  end

  context "#valid?" do

    context "should return false" do

      it "if entry does not presence in config file" do
        @params['value']=nil
	subject.new(*params).should_not be_valid
      end

      it "if data in config file has wrong type" do
        @params['type']=Array
        @params['value']='string'
	subject.new(*params).should_not be_valid
      end

      it "if child value is not valid" do
	@params['type']=Hash
	@params['value']={:value => 100500}
	values_block = lambda {
	  value :type => String
	}
	subject.new(*params,&values_block).should_not be_valid
      end

      context "with type => Array", :wip => true do

	it "if actual data is not array" do
	  @params['type']=Array
	  @params['value']=123
	  subject.new(*params).should_not be_valid
	end

	it "if actual data is an array of wrong hashes" do
	  @params['type']=Array
	  @params['value']=[1,2]
	  values_block = lambda {
	    value1 :type => String
	    value2 :type => Fixnum
	  }
	  subject.new(*params,&values_block).should_not be_valid
	end

      end

    end

    context "should return true" do

      it "if entry presence and has right type" do
	subject.new(*params).should be_valid
      end

      it "if valid itself and child values valid too" do
	@params['type']=Hash
	@params['value']={'value' => 'some data'}
	values_block = lambda {
	  value :type => String
	}
	subject.new(*params,&values_block).should be_valid
      end

      context "with type => Array", :wip => true do

	it "if actual data is an array of right hashes" do
	  @params['type']=Array
	  @params['value']=[
	    {'value1' =>'qwe', 'value2' => 123 },
	    {'value1' =>'rty', 'value2' => 456 }
	  ]
	  values_block = lambda {
	    value1 :type => String
	    value2 :type => Fixnum
	  }
	  subject.new(*params,&values_block).should be_valid
	end

      end

    end

  end

  context "#error_message" do

    subject { described_class.new(*params) }

    context "should generate correct error message when no data" do

      it "with full description" do
        @params['name'] = 'database'
        @params['value'] = nil
        @params['type'] = String
        @params['desc'] = 'Database name'
        @params['example'] = 'localhost'
        subject.error_message.should eq("  database: localhost # does not exists(Database name), String")
      end

      it "without example value" do
        @params['name'] = 'database'
        @params['value'] = nil
        @params['type'] = String
        @params['desc'] = 'Database name'
        @params.delete('example')
        subject.error_message.should eq("  database:  # does not exists(Database name), String")
      end

      it "without description" do
        @params['name'] = 'database'
        @params['value'] = nil
        @params['type'] = String
        @params.delete('desc')
        @params['example'] = 'localhost'
        subject.error_message.should eq("  database: localhost # does not exists, String")
      end

      it "without example and description" do
        @params['name'] = 'database'
        @params['value'] = nil
        @params['type'] = String
        @params.delete('desc')
        @params.delete('example')
        subject.error_message.should eq("  database:  # does not exists, String")
      end

    end

    context "should generate correct error message when data is of wrong type" do

      it "with full description" do
        @params['name'] = 'database'
        @params['value'] = 20
        @params['type'] = String
        @params['desc'] = 'Database name'
        @params['example'] = 'localhost'
        subject.error_message.should eq("  database: 20 # wrong type,should be String(Database name)")
      end

      it "without example value" do
        @params['name'] = 'database'
        @params['value'] = 20
        @params['type'] = String
        @params['desc'] = 'Database name'
        @params.delete('example')
        subject.error_message.should eq("  database: 20 # wrong type,should be String(Database name)")
      end

      it "without description" do
        @params['name'] = 'database'
        @params['value'] = 20
        @params['type'] = String
        @params.delete('desc')
        @params['example'] = 'localhost'
        subject.error_message.should eq("  database: 20 # wrong type,should be String")
      end

      it "without example and description" do
        @params['name'] = 'database'
        @params['value'] = 20
        @params['type'] = String
        @params.delete('desc')
        @params.delete('example')
        subject.error_message.should eq("  database: 20 # wrong type,should be String")
      end

    end

  end
end
