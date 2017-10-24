require 'spec_helper'

describe Indocker::Configs::Config do
  subject { described_class.new }

  context 'restricts to use reserved keywords' do
    it 'raise Indocker::Errors::ReservedKeywordUsed "option" name' do
      expect{
        subject.option(:config)
      }.to raise_error(Indocker::Errors::ReservedKeywordUsed)
    end

    it 'restrict to use "config" name' do
      expect{
        subject.config('hash_config')
      }.to raise_error(Indocker::Errors::ReservedKeywordUsed)
    end

    it 'restrict to use "hash_config" name' do
      expect{
        subject.hash_config(:option)
      }.to raise_error(Indocker::Errors::ReservedKeywordUsed)
    end
  end

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
    it 'creates getter and subconfiguration object for single option' do
      subject.config(:example_config) do
        option(:key1)
        option(:key2, type: :array)
      end

      subject.example_config.key1('value1')
      subject.example_config.key2(['value2'])

      expect(subject.example_config.key1).to eq('value1')
      expect(subject.example_config.key2).to match(['value2'])
    end

    it 'creates getter and subconfig for subconfiguration' do
      subject.config(:parent_config) do
        config(:child_config) do
          option(:child_option)
        end
      end
      
      subject.parent_config.child_config.child_option('Hello World')
      
      expect(subject.parent_config.child_config.child_option).to eq('Hello World')
    end
  end

  describe '#hash_config' do
    it 'create subconfiguration for each hash_config key' do
      subject.hash_config(:multi) do
        option(:key1)
      end

      subject.multi(:config1) do
        key1('value 1')
      end

      subject.multi(:config2) do
        key1('value 2')
      end
      
      expect(subject.config1.key1).to eq('value 1')
      expect(subject.config2.key1).to eq('value 2')
    end
  end
end