require 'spec_helper'

describe AppSent do

  let(:fixtures_path) { File.expand_path(File.join(File.dirname(__FILE__),'fixtures')) }

  before :each do
    AppSent.class_variable_set(:@@config_path,nil)
    AppSent.class_variable_set(:@@environment,nil)
    AppSent.class_variable_set(:@@config_files,[])
  end

  context ".new" do

    subject { AppSent.new }

    %w(all_valid? load! full_error_message).each do |method|
      it { should respond_to(method) }
    end

  end

  context ".init" do

    before :each do
      @right_params = { :path => 'fixtures', :env => 'test' }
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
      AppSent.config_path.should eq(fixtures_path)
    end

    it "should save environment to @@environment" do
      AppSent.init(@right_params) do; end
      AppSent.send(:class_variable_get,:@@environment).should eq('test')
    end

    it "should save array of configs to @@configs" do
      AppSent.init(@right_params) do
        simple_config
        database do
          username :type => String
          password :type => String
          port     :type => Fixnum
        end

        simple_config_with_just_type :type => Array
      end
      AppSent.config_files.should eq(%w(simple_config database simple_config_with_just_type))
    end

    context "should send right variables to AppSent::ConfigFile" do

      let(:mock_config_file) { mock(AppSent::ConfigFile, :valid? => true, :constantized => 'STR', :data => 'data') }

      it "in a simple case" do
        AppSent::ConfigFile.should_receive(:new).once.with(
          File.join(File.dirname(__FILE__),'config'),
          'confname',
          'env'
        ).and_return(mock_config_file)

        AppSent.init(:path => 'config', :env => 'env') do
          confname
        end
      end

      it "with &block" do
        block = lambda {}
        AppSent::ConfigFile.should_receive(:new).once.with(
          File.join(File.dirname(__FILE__),'config'),
          'confname',
          'env',
          &block
        ).and_return(mock_config_file)

        AppSent.init(:path => 'config', :env => 'env') do
          confname &block
        end
      end

      it "with :skip_env" do
        pending('unimplemented yet')
        block = lambda {}
        AppSent::ConfigFile.should_receive(:new).once.with(
          File.join(File.dirname(__FILE__),'config'),
          'confname',
          'env',
          :skip_env => true,
          &block
        ).and_return(mock_config_file)

        AppSent.init(:path => 'config', :env => 'env') do
          confname :skip_env => true, &block
        end
      end

      after :each do
        AppSent.send :remove_const, 'STR' if AppSent.const_defined?("STR")
      end

    end

    it "should create corresponding constants with values" do
      AppSent.init(@right_params) do
        simple_config
        database do
          username :type => String
          password :type => String
          port     :type => Fixnum
        end

        simple_config_with_just_type :type => Array
      end

      AppSent::SIMPLE_CONFIG.should eq({:a=>1, :b=>'2'})
      AppSent::DATABASE.should eq({:username => 'user', :password => 'pass', :port => 100500})
      AppSent::SIMPLE_CONFIG_WITH_JUST_TYPE.should eq([1,2,3])
    end

  end

end
