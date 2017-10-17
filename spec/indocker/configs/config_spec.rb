require 'spec_helper'

describe Indocker::Configs::Config do
  subject { described_class.new }

  describe '#option' do
    it 'creates setter and getter methods with the same name' do
      subject.option(:some_key, group: :default, type: :string)
      subject.some_key('some_value')

      expect(subject.some_key).to eq('some_value')
    end

    it 'validates setter value with :type attribute' do
      subject.option(:some_key, group: :default, type: :boolean)

      expect{
        subject.some_key('test')
      }.to raise_error(Indocker::Errors::ConfigOptionTypeMismatch, 'Expected option :some_key => "test" to be a :boolean, not a :string')
    end
  end

  describe '#config' do
    it 'creates getter and subconfiguration object' do
      subject.config(:example_config) do
        option(:key1)
        option(:key2, type: :array)
      end

      subject.example_config.key1('value1')
      subject.example_config.key2(['value2'])

      expect(subject.example_config.key1).to eq('value1')
      expect(subject.example_config.key2).to match(['value2'])
    end
  end
end