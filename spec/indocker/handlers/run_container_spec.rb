require 'spec_helper'

describe 'Indocker::Handlers::RunContainer' do
  subject { ioc.run_container_handler }

  describe '#handle' do
    context 'for valid cmd process in container' do
      let(:container) { ioc.container_metadata_repository.get_container(:indocker_correct_container) }
    
      before do
        Indocker.define_image :indocker_correct_image do
          from 'alpine:latest'
          
          cmd  '/bin/sh'
        end

        Indocker.define_container :indocker_correct_container do
          use images.indocker_correct_image
        end
      end

      context 'for new container' do
        before do
          subject.handle(name: :indocker_correct_container)
        end
        
        it 'creates new container' do
          expect(
            ioc.docker_api.container_exists_by_name?(:indocker_correct_container)
          ).to be true
        end

        it 'runs new container' do
          expect(
            ioc.docker_api.find_container_by_id(container.container_id).info["State"]["Running"]
          ).to be true
        end

        it 'logs successfull result' do
          expect(
            ioc.logger.messages.last
          ).to eq("INFO".colorize(:green) + ": Successfully started container :indocker_correct_container")
        end
      end

      context 'for existing container' do
        before do
          subject.handle(name: :indocker_correct_container)
        end

        it 'stops container' do
          expect_any_instance_of(Docker::Container).to receive(:stop)
          
          subject.handle(name: :indocker_correct_container)
        end

        it 'runs container again' do
          subject.handle(name: :indocker_correct_container)

          expect(
            ioc.docker_api.find_container_by_id(container.container_id).info["State"]["Running"]
          ).to be true
        end

        it 'logs successfull result' do
          expect(
            ioc.logger.messages.last
          ).to eq("INFO".colorize(:green) + ": Successfully started container :indocker_correct_container")
        end
      end

      context 'with --rebuild option' do
        before do
          subject.handle(name: :indocker_correct_container, rebuild: true)
        end
        
        it 'builds image again' do
          expect(
            ioc.docker_api.image_exists_by_repo?(:indocker_correct_image)
          ).to be true
        end

        it 'runs container' do
          expect(
            ioc.docker_api.find_container_by_id(container.container_id).info["State"]["Running"]
          ).to be true
        end

        it 'logs successfull result' do
          expect(
            ioc.logger.messages.last
          ).to eq("INFO".colorize(:green) + ": Successfully started container :indocker_correct_container")
        end
      end
    end
    
    context 'for falling cmd process in container' do
      let(:container) { ioc.container_metadata_repository.get_container(:container_with_cmd_error) }

      before do
        Indocker.define_image :indocker_image_with_cmd_error do
          from 'alpine:latest'
          
          cmd  'invalid/process'
        end

        Indocker.define_container :container_with_cmd_error do
          use images.indocker_image_with_cmd_error
        end

        subject.handle(name: :container_with_cmd_error)
      end
      
      it 'logs error text' do
        expect(
          ioc.logger.messages.last
        ).to eq("ERROR".colorize(:red) + ": /bin/sh: invalid/process: not found\r")
      end

      it 'does not run container' do
        expect(
          ioc.docker_api.find_container_by_id(container.container_id).info["State"]["Running"]
        ).to be false
      end
    end
  end
end