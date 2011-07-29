require 'spec_helper'

describe Array do

  context "#ask_all?" do

    let(:string_receiver) { double(String) }
    let(:fixnum_receiver) { double(Fixnum) }
    let(:good_mock_array) { [string_receiver,string_receiver,string_receiver] }
    let(:bad_mock_array) { [string_receiver,fixnum_receiver,string_receiver] }
    let(:good) { ['a','b','c'] }
    let(:bad)  { ['a',100,'c'] }

    it "should ask all elements" do
      string_receiver.should_receive(:class).exactly(3).times.and_return(String)
      good_mock_array.ask_all? { |e| e.class == String }.should be_true
    end

    it "should ask all elements" do
      string_receiver.should_receive(:class).twice.and_return(String)
      fixnum_receiver.should_receive(:class).once.and_return(Fixnum)
      bad_mock_array.ask_all? { |e| e.class == String }.should be_false
    end

    it "should return true" do
      good.ask_all? { |e| e.class == String }.should be_true
    end

    it "should return false" do
      bad.ask_all? { |e| e.class == String }.should be_false
    end

  end

end
