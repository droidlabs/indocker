require 'spec_helper'

describe Indocker::ImageDirectives::DockerCp do
  describe '#initialize' do
    subject {
      described_class.new('example_container', 'path/to/build_dir', passed_context) do
        copy sample_variable => one_more_variable
      end
    }

    let(:passed_context) {
      {
        sample_variable:   'sample_value',
        one_more_variable: 'one_more_value'
      }
    }
    
    it 'evaluates block content with passed context' do
      expect(subject.copy_actions).to match({ 
        'sample_value' => 'one_more_value' 
      })
    end
  end
end