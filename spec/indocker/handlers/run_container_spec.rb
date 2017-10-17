require 'spec_helper'

describe 'Indocker::Handlers::RunContainer' do
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

      context 'for existing container' do
        before do
          subject.handle(name: :indocker_correct_container, current_path: nil)
        end

        it 'stops, destroy and create container again' do
          old_container_id = ioc.docker_api.get_container_id(:indocker_correct_container)
          
          subject.handle(name: :indocker_correct_container, current_path: nil)

          new_container_id = ioc.docker_api.get_container_id(:indocker_correct_container)

          expect(new_container_id).not_to eq(old_container_id)
        end

        it 'runs container again' do
          subject.handle(name: :indocker_correct_container, current_path: nil)

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
        
        subject.handle(name: :container_with_falling_cmd, current_path: nil)
      end
      
      it 'logs error text' do
        expect(
          ioc.logger.messages.last
        ).to eq("ERROR".colorize(:red) + ": oci runtime error: container_linux.go:265: starting container process caused \"exec: \\\"invalid/process\\\": stat invalid/process: no such file or directory\"")
      end

      it 'does not run container' do
        expect(
          ioc.docker_api.get_container_state(:container_with_falling_cmd)
        ).to eq(Indocker::ContainerMetadata::States::CREATED)
      end
    end
  end
end