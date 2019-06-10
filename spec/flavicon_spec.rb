# frozen_string_literal: true

require 'flavicon'

describe Flavicon do
  describe '::find' do
    let(:finder) { instance_spy Flavicon::Finder }

    before do
      allow(Flavicon::Finder).to receive(:new).and_return(finder)
    end

    it 'calls find on Finder instance' do
      allow(finder).to receive(:find).and_return('http://www.example.com/favicon.ico')
      expect(described_class.find('http://www.example.com')).to eq('http://www.example.com/favicon.ico')
    end
  end
end
