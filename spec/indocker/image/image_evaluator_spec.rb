require 'spec_helper'

describe 'Indocker::ImageEvaluator' do
  subject       { ioc.image_evaluator }
  let(:context) { Indocker::DSLContext.new(build_dir: 'some/path') }

  before do    
    Indocker.define_partial 'example_partial' do
      set_arg(:wait_connection,      true)
      set_arg(:notification_enabled, true)
    
      before_build do
        docker_cp 'yet_anoter_helper_container' do
          copy '.' => '.'
        end
      end

      run "echo '#{wait_connection}'"
      run "echo '#{notification_enabled}'"
    end
  end

  context 'directives list' do
    let(:example_image_definition) do
      Proc.new do
        set_arg(:environment, :stading)
        set_arg(:server,      :development)
      
        before_build do
          docker_cp 'helper_container' do
            copy '.' => '.'
          end
        end
      
        from 'ruby:2.3.1'
      
        partial 'example_partial', wait_connection: false, notification_enabled: true
    
        workdir '/app'
    
        run "echo 'Hello World'"
      end
    end
    
    let(:directives) { subject.evaluate(context, &example_image_definition) }

    it 'returns array of directives' do
      expect(directives).to be_a(Array)
    end

    it 'returns valid count of directives' do
      expect(directives.size).to eq(7)
    end

    it 'rerurns proper directives classes' do
      expect(directives[0]).to be_a(Indocker::ImageDirectives::DockerCp)
      expect(directives[1]).to be_a(Indocker::ImageDirectives::From)
      expect(directives[2]).to be_a(Indocker::ImageDirectives::DockerCp)
      expect(directives[3]).to be_a(Indocker::ImageDirectives::Run)
      expect(directives[4]).to be_a(Indocker::ImageDirectives::Run)
      expect(directives[5]).to be_a(Indocker::ImageDirectives::Workdir)
      expect(directives[6]).to be_a(Indocker::ImageDirectives::Run)
    end
  end

  context 'with partial with options' do
    let(:image_with_partial_definition) {
      Proc.new do
        partial :partial_directive, some_arg: 'some_arg_value'
      end
    }

    before(:all) do
      Indocker.define_partial :partial_directive do
        run "echo #{some_arg}"
      end
    end

    it 'generates valid dockerfile' do
      partial_directive = subject.evaluate(context, &image_with_partial_definition).first

      expect(partial_directive.to_s).to eq(%q(RUN "echo some_arg_value"))
    end
  end
end