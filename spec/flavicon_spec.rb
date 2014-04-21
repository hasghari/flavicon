require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'flavicon'

describe Flavicon do
  describe '::find' do
    it 'should delegate to Finder' do
      double = double('Finder').as_null_object
      Flavicon::Finder.should_receive(:new).with('http://www.example.com').and_return(double)
      Flavicon.find('http://www.example.com')
    end

    it 'should call find on Finder instance' do
      double = double('Finder', find: 'http://www.example.com/favicon.ico')
      Flavicon::Finder.should_receive(:new).with('http://www.example.com').and_return(double)
      Flavicon.find('http://www.example.com').should eq('http://www.example.com/favicon.ico')
    end
  end
end
