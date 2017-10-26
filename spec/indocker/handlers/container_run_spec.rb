require 'spec_helper'

describe 'Indocker::Handlers::ContainerRun' do
  subject { ioc.run_container_handler }

  describe '#handle' do
    context 'for valid cmd process in container' do
      let(:container) { ioc.container_metadata_repository.get_by_name(:indocker_correct_container) }
    
      before do
        Indocker.define_image :indocker_correct_image do
          from 'alpine:latest'
          
          cmd  ['/bin/sh']
        end

        Indocker.define_container :indocker_correct_container do
          use images.indocker_correct_image
        end
      end

      context 'for new container' do
        before do
          subject.handle(name: :indocker_correct_container, current_path: nil)
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
      let(:container) { ioc.container_metadata_repository.get_by_name(:container_with_falling_cmd) }

      before do
        Indocker.define_image :indocker_image_with_falling_cmd do
          from 'alpine:latest'
          
          cmd  ['invalid/process']
        end

        Indocker.define_container :container_with_falling_cmd do
          use images.indocker_image_with_falling_cmd
        end
      end
      
      it 'raises Docker::Error::ClientError error' do
        expect(
          subject.handle(name: :container_with_falling_cmd, current_path: nil)
        ).to raise_error(Docker::Error::ClientError)
      end
    end
  end
end