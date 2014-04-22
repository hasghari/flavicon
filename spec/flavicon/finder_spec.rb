require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'flavicon/finder'

describe Flavicon::Finder do
  def html(file)
    File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/#{file}"))
  end

  subject { Flavicon::Finder.new('http://www.ex.com') }

  describe '#find' do
    it 'should delegate to #request' do
      response = double('response', body: html('absolute.html'))
      subject.should_receive(:request).with('http://www.ex.com').and_return([response, 'http://www.other.com'])
      subject.should_receive(:valid_favicon_url?).and_return(true)
      subject.find
    end

    it 'should extract favicon from body' do
      response = double('response', body: html('absolute.html'))
      subject.should_receive(:request).with('http://www.ex.com').and_return([response, 'http://www.other.com'])
      subject.should_receive(:valid_favicon_url?).with('http://sub.example.com/absolute.ico').and_return(true)
      subject.find.should == 'http://sub.example.com/absolute.ico'
    end

    it 'should fallback to default when response is empty' do
      response = double('response', body: '')
      subject.should_receive(:request).with('http://www.ex.com').and_return([response, 'http://www.other.com'])
      subject.should_receive(:valid_favicon_url?).with('http://www.other.com/favicon.ico').and_return(true)
      subject.find.should == 'http://www.other.com/favicon.ico'
    end

    it 'should return nil when not valid' do
      response = double('response', body: html('absolute.html'))
      subject.should_receive(:request).with('http://www.ex.com').and_return([response, 'http://www.other.com'])
      subject.should_receive(:valid_favicon_url?).and_return(false)
      subject.find.should be_nil
    end
  end

  describe '#valid_favicon_url?' do
    let(:favicon_url) { 'http://www.ex.com/favicon.ico' }
    let(:response) do
      { status: 200, body: 'blah', headers: { 'Content-Type' => 'image/x-icon'} }
    end

    before do
      stub_request(:get, favicon_url).to_return(response)
    end

    it 'should be true by default' do
      subject.valid_favicon_url?(favicon_url).should be_true
    end

    context 'http failure' do
      let(:response) do
        { status: 400, body: 'blah', headers: { 'Content-Type' => 'image/x-icon'} }
      end

      it 'should be false' do
        subject.valid_favicon_url?(favicon_url).should be_false
      end
    end

    context 'empty body' do
      let(:response) do
        { status: 200, body: '', headers: { 'Content-Type' => 'image/x-icon'} }
      end

      it 'should be false' do
        subject.valid_favicon_url?(favicon_url).should be_false
      end
    end

    context 'invalid content-type' do
      let(:response) do
        { status: 200, body: 'blah', headers: { 'Content-Type' => 'text/javascript'} }
      end

      it 'should be false' do
        subject.valid_favicon_url?(favicon_url).should be_false
      end
    end
  end

  describe '#extract_from_html' do
    it 'should return nil for empty body' do
      subject.extract_from_html('', 'http://www.ex.com').should be_nil
    end

    it 'should return nil if no favicon found' do
      subject.extract_from_html(html('missing.html'), 'http://www.ex.com').should be_nil
    end

    it 'should handle absolute url' do
      subject.extract_from_html(html('absolute.html'), 'http://www.ex.com')
        .should == 'http://sub.example.com/absolute.ico'
    end

    it 'should handle relative url' do
      subject.extract_from_html(html('relative.html'), 'http://www.ex.com')
        .should == 'http://www.ex.com/relative.ico'
    end

    it 'should return first if multiple matches' do
      subject.extract_from_html(html('multiple.html'), 'http://www.ex.com')
        .should == 'http://www.ex.com/first.ico'
    end
  end

  describe '#default_path' do
    it 'should return default favicon url' do
      subject.default_path('http://www.basic.com').should == 'http://www.basic.com/favicon.ico'
    end

    it 'ignores query and fragment' do
      subject.default_path('http://www.basic.com?query=a#fragment').should == 'http://www.basic.com/favicon.ico'
    end

    it 'ignores path with no trailing slash' do
      subject.default_path('http://www.basic.com/basic').should == 'http://www.basic.com/favicon.ico'
    end

    it 'ignores path with trailing slash' do
      subject.default_path('http://www.basic.com/basic/').should == 'http://www.basic.com/favicon.ico'
    end
  end

  describe '#request' do
    before do
      stub_request(:get, 'http://www.ex.com/abc/')
        .to_return(status: 200, body: '', headers: {})
    end

    it 'should raise error when redirect limit reached' do
      expect {
        subject.request('http://www.ex.com', -1)
      }.to raise_error(Flavicon::Finder::TooManyRedirects)
    end

    it 'should return response and url when successful' do
      response, url = subject.request('http://www.ex.com/abc/')
      response.should be_a Net::HTTPSuccess
      url.should == 'http://www.ex.com/abc/'
    end

    context 'ssl' do
      before do
        stub_request(:get, 'http://secure.ex.com:443/abc/')
          .to_return(status: 200, body: '', headers: {})
      end

      it 'should set http secure state' do
        Net::HTTP.any_instance.should_receive(:use_ssl=).with(true)
        Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        response, url = subject.request('https://secure.ex.com/abc/')
        response.should be_a Net::HTTPSuccess
        url.should == 'https://secure.ex.com/abc/'
      end
    end

    context 'redirect' do
      before do
        stub_request(:get, 'http://www.ex.com/abc')
          .to_return(status: 301, body: '', headers: { 'Location' => 'http://www.ex.com/abc/' })
      end

      it 'should follow redirect responses' do
        response, resolved = subject.request('http://www.ex.com/abc')
        response.should be_a Net::HTTPSuccess
        resolved.should == 'http://www.ex.com/abc/'
      end

      it 'should recurse' do
        subject.should_receive(:request).with('http://www.ex.com/abc', 2).and_call_original
        subject.should_receive(:request).with('http://www.ex.com/abc/', 1)
        subject.request('http://www.ex.com/abc', 2)
      end

      it 'should handle relative redirect urls' do
        stub_request(:get, 'http://www.ex.com/def')
          .to_return(status: 301, body: '', headers: { 'Location' => '/ghi/' })

        subject.should_receive(:request).with('http://www.ex.com/def').and_call_original
        subject.should_receive(:request).with('http://www.ex.com/ghi/', 9)
        subject.request('http://www.ex.com/def')
      end
    end
  end
end
