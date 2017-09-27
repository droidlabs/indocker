require 'spec_helper'

describe 'Indocker::ImageEvaluator' do
  subject { ioc.image_evaluator }

  before do
    Indocker.define_image 'example_image' do
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
    let(:image_metadata) { ioc.image_repository.find_by_repo('example_image') }
    let(:commands)       { subject.evaluate(Indocker::ImageContext.new, &image_metadata.definition) }

    it 'returns array of commands' do
      expect(commands).to be_a(Array)
    end

    it 'returns valid count of commands' do
      expect(commands.size).to eq(7)
    end

    it 'rerurns proper commands classes' do
      expect(commands[0]).to be_a(Indocker::PrepareCommands::DockerCp)
      expect(commands[1]).to be_a(Indocker::Commands::From)
      expect(commands[2]).to be_a(Indocker::PrepareCommands::DockerCp)
      expect(commands[3]).to be_a(Indocker::Commands::Run)
      expect(commands[4]).to be_a(Indocker::Commands::Run)
      expect(commands[5]).to be_a(Indocker::Commands::Workdir)
      expect(commands[6]).to be_a(Indocker::Commands::Run)
    end
  end
end