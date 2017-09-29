require 'spec_helper'

describe 'Indocker::ImageEvaluator' do
  subject { ioc.image_evaluator }

  before do    
    Indocker.define_partial 'example_partial' do
      set_arg(:wait_connection,      true)
      set_arg(:notification_enabled, true)
    
      before_build do
        docker_cp 'yet_anoter_helper_container' do
          copy '.', '.'
        end
      end

      run "echo '#{wait_connection}'"
      run "echo '#{notification_enabled}'"
    end
  end

  context 'commands list' do
    let(:example_image_definition) do
      Proc.new do
        set_arg(:environment, :stading)
        set_arg(:server,      :development)
      
        before_build do
          docker_cp 'helper_container' do
            copy '.', '.'
          end
        end
      
        from 'ruby:2.3.1'
      
        partial 'example_partial', wait_connection: false, notification_enabled: true
    
        workdir '/app'
    
        run "echo 'Hello World'"
      end
    end
    
    let(:context)        { Indocker::ImageContext.new(build_dir: 'some/path') }
    let(:commands)       { subject.evaluate(context, &example_image_definition) }

    it 'returns array of commands' do
      expect(commands).to be_a(Array)
    end

    it 'returns valid count of commands' do
      expect(commands.size).to eq(7)
    end

    it 'rerurns proper commands classes' do
      expect(commands[0]).to be_a(Indocker::PrepareDirectives::DockerCp)
      expect(commands[1]).to be_a(Indocker::DockerDirectives::From)
      expect(commands[2]).to be_a(Indocker::PrepareDirectives::DockerCp)
      expect(commands[3]).to be_a(Indocker::DockerDirectives::Run)
      expect(commands[4]).to be_a(Indocker::DockerDirectives::Run)
      expect(commands[5]).to be_a(Indocker::DockerDirectives::Workdir)
      expect(commands[6]).to be_a(Indocker::DockerDirectives::Run)
    end
  end
end