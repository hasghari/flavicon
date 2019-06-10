# frozen_string_literal: true

require 'flavicon/finder'

describe Flavicon::Finder do
  def html(file)
    File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/#{file}"))
  end

  let(:finder) { described_class.new('http://www.ex.com') }

  describe '#find' do
    let(:favicon_url) { 'http://sub.example.com/absolute.ico' }
    let(:response) { instance_double(Net::HTTPResponse, body: html('absolute.html')) }

    before do
      allow(finder).to receive(:request).and_return([response, 'http://www.other.com'])
      allow(finder).to receive(:verify_favicon_url).and_return(favicon_url)
    end

    it 'delegates to #request' do
      finder.find
      expect(finder).to have_received(:request).with('http://www.ex.com')
    end

    it 'delegates to #verify_favicon_url' do
      finder.find
      expect(finder).to have_received(:verify_favicon_url).with('http://sub.example.com/absolute.ico')
    end

    it 'extracts favicon from body' do
      expect(finder.find).to eq 'http://sub.example.com/absolute.ico'
    end

    context 'when favicon url is nil' do
      let(:favicon_url) { nil }

      it 'returns nil' do
        expect(finder.find).to be_nil
      end
    end
  end

  describe '#verify_favicon_url' do
    let(:favicon_url) { 'http://www.ex.com/favicon.ico' }
    let(:response) do
      { status: 200, body: 'blah', headers: { 'Content-Type' => 'image/x-icon' } }
    end

    before do
      stub_request(:get, favicon_url).to_return(response)
    end

    it 'returns favicon url' do
      expect(finder.verify_favicon_url(favicon_url)).to eq favicon_url
    end

    context 'with http failure' do
      let(:response) do
        { status: 400, body: 'blah', headers: { 'Content-Type' => 'image/x-icon' } }
      end

      it 'returns nil' do
        expect(finder.verify_favicon_url(favicon_url)).to be_nil
      end
    end

    context 'with empty body' do
      let(:response) do
        { status: 200, body: '', headers: { 'Content-Type' => 'image/x-icon' } }
      end

      it 'returns nil' do
        expect(finder.verify_favicon_url(favicon_url)).to be_nil
      end
    end

    context 'with invalid content-type' do
      let(:response) do
        { status: 200, body: 'blah', headers: { 'Content-Type' => 'text/javascript' } }
      end

      it 'returns nil' do
        expect(finder.verify_favicon_url(favicon_url)).to be_nil
      end
    end
  end

  describe '#extract_from_html' do
    it 'returns nil for empty body' do
      expect(finder.extract_from_html('', 'http://www.ex.com')).to be_nil
    end

    it 'returns nil if no favicon found' do
      expect(finder.extract_from_html(html('missing.html'), 'http://www.ex.com')).to be_nil
    end

    it 'handles absolute url' do
      expect(finder.extract_from_html(html('absolute.html'), 'http://www.ex.com'))
        .to eq('http://sub.example.com/absolute.ico')
    end

    it 'handles relative url' do
      expect(finder.extract_from_html(html('relative.html'), 'http://www.ex.com'))
        .to eq('http://www.ex.com/relative.ico')
    end

    it 'returns first if multiple matches' do
      expect(finder.extract_from_html(html('multiple.html'), 'http://www.ex.com')).to eq 'http://www.ex.com/first.ico'
    end
  end

  describe '#default_path' do
    it 'returns default favicon url' do
      expect(finder.default_path('http://www.basic.com')).to eq 'http://www.basic.com/favicon.ico'
    end

    it 'ignores query and fragment' do
      expect(finder.default_path('http://www.basic.com?query=a#fragment')).to eq 'http://www.basic.com/favicon.ico'
    end

    it 'ignores path with no trailing slash' do
      expect(finder.default_path('http://www.basic.com/basic')).to eq 'http://www.basic.com/favicon.ico'
    end

    it 'ignores path with trailing slash' do
      expect(finder.default_path('http://www.basic.com/basic/')).to eq 'http://www.basic.com/favicon.ico'
    end
  end

  describe '#request' do
    before do
      stub_request(:get, 'http://www.ex.com/abc/')
        .to_return(status: 200, body: '', headers: {})
    end

    it 'raises error when redirect limit reached' do
      expect { finder.request('http://www.ex.com', -1) }.to raise_error Flavicon::Finder::TooManyRedirects
    end

    it 'returns response and url when successful' do
      expect(finder.request('http://www.ex.com/abc/')).to match [an_instance_of(Net::HTTPOK), 'http://www.ex.com/abc/']
    end

    context 'with ssl' do
      let(:http) { instance_spy Net::HTTP }

      before do
        allow(Net::HTTP).to receive(:new).and_return(http)
      end

      it 'sets http secure state' do
        finder.request('https://secure.ex.com/abc/')
        expect(http).to have_received(:use_ssl=).with(true)
      end

      it 'sets verify mode' do
        finder.request('https://secure.ex.com/abc/')
        expect(http).to have_received(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      end
    end

    context 'with secure url' do
      before do
        stub_request(:get, 'https://secure.ex.com/abc/').to_return(status: 200, body: '', headers: {})
      end

      it 'returns secure url' do
        expect(finder.request('https://secure.ex.com/abc/'))
          .to match [an_instance_of(Net::HTTPOK), 'https://secure.ex.com/abc/']
      end
    end

    context 'with redirect' do
      before do
        stub_request(:get, 'http://www.ex.com/abc')
          .to_return(status: 301, body: '', headers: { 'Location' => 'http://www.ex.com/abc/' })
      end

      it 'follows redirect responses' do
        expect(finder.request('http://www.ex.com/abc')).to match [an_instance_of(Net::HTTPOK), 'http://www.ex.com/abc/']
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'recurses' do
        allow(finder).to receive(:request).and_call_original
        finder.request('http://www.ex.com/abc', 2)
        expect(finder).to have_received(:request).with('http://www.ex.com/abc', 2).ordered
        expect(finder).to have_received(:request).with('http://www.ex.com/abc/', 1).ordered
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'handles relative redirect urls' do
        stub_request(:get, 'http://www.ex.com/def').to_return(status: 301, body: '', headers: { 'Location' => '/ghi/' })

        allow(finder).to receive(:request).with('http://www.ex.com/def').and_call_original
        allow(finder).to receive(:request).with('http://www.ex.com/ghi/', 9)
        finder.request('http://www.ex.com/def')
        expect(finder).to have_received(:request).with('http://www.ex.com/ghi/', 9)
      end
    end
  end
end
