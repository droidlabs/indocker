require 'spec_helper'

describe 'Indocker::Handlers::ContainerRun' do
  describe '#handle' do
    after(:all) { truncate_docker_items }
    
    before(:all) do
      Indocker.define_image :indocker_image do
        from 'alpine:latest'
        
        cmd  ['/bin/sh']
      end
    end
    context 'for valid cmd process in container' do
      context 'for new container' do
        before(:all) do
          Indocker.define_container :indocker_correct_container do
            use images.find_by_repo(:indocker_image)
          end

          ioc.run_container_handler.handle(name: :indocker_correct_container, current_path: nil)
        end
        
        it 'creates container' do
          expect(
            ioc.docker_api.container_exists?(:indocker_correct_container)
          ).to be true
        end

        it 'runs container' do
          expect(
            ioc.docker_api.get_container_state(:indocker_correct_container)
          ).to eq(Indocker::ContainerMetadata::States::RUNNING)
        end

        it 'logs successfull result' do
          expect(
            ioc.logger.messages.last
          ).to eq("INFO".colorize(:green) + ": Successfully started container :indocker_correct_container")
        end
      end
    end
    
    context 'for falling cmd process in container' do
      before(:all) do
        Indocker.define_container :container_with_falling_cmd do
          use images.find_by_repo(:indocker_image)

          cmd ['invalid_command']
        end
      end
      
      it 'raises Docker::Error::ClientError error' do
        expect{
          ioc.run_container_handler.handle(name: :container_with_falling_cmd, current_path: nil)
        }.to raise_error(Docker::Error::ClientError)
      end
    end
  end
end