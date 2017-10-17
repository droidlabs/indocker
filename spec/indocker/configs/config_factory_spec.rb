require 'spec_helper'

describe Indocker::Configs::ConfigFactory do
  subject { ioc.config }

  it 'returns Indocker::Configs::Config object' do
    expect(subject).to be_a(Indocker::Configs::Config)
  end

  context '#option' do
    it 'pass method to Indocker::Configs::Config object' do
      subject.option(:example_method)
      subject.example_method('example_value')

      expect(subject.example_method).to eq('example_value')
    end
  end
end