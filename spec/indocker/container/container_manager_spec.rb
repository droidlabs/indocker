require 'spec_helper'

describe Indocker::ContainerManager do
  before(:all) do
    Indocker.define_image 'indocker_image' do
      from 'alpine:latest'
      cmd %w(ls)
    end

    ioc.image_builder.build('indocker_image')

    Indocker.define_container 'indocker_container' do
      use images.find_by_repo(:indocker_image)
    end
  end

  after(:all) { truncate_docker_items }

  describe '#run' do
    before(:all) { ioc.container_manager.run('indocker_container') }
    after(:all)  { ioc.docker_api.delete_container('indocker_container') }

    it 'creates container' do
      expect(
        ioc.docker_api.container_exists?('indocker_container')
      ).to be true
    end

    it 'starts container' do
      sleep 1 # wait when container stops

      expect(
        ioc.docker_api.get_container_state('indocker_container')
      ).to eq(Indocker::ContainerMetadata::States::EXITED)
    end
  end

  describe '#create' do
    before(:all) { ioc.container_manager.create('indocker_container') }
    after(:all)  { ioc.docker_api.delete_container('indocker_container') }

    it 'creates container' do
      expect(
        ioc.docker_api.container_exists?('indocker_container')
      ).to be true
    end
  end

  describe '#start' do
    context 'with ready timeout' do
      context 'if ready returns true' do
        before(:all) do
          Indocker.define_container 'indocker_timeout_container' do
            use images.find_by_repo(:indocker_image)

            ready sleep: 0.1, timeout: 1 do
              sleep 0.5
              true
            end
          end

          ioc.container_manager.create('indocker_timeout_container')
        end

        it 'starts container if ready_block returns true' do
          ioc.container_manager.start('indocker_timeout_container')

          sleep 1 # wait when container stops

          expect(
            ioc.docker_api.get_container_state('indocker_timeout_container')
          ).to eq(Indocker::ContainerMetadata::States::EXITED)
        end
      end

      context 'if ready returns false' do
        before(:all) do
          Indocker.define_container 'indocker_timeout_error_container' do
            use images.find_by_repo(:indocker_image)

            ready sleep: 0.1, timeout: 1 do
              false
            end
          end

          ioc.container_manager.create('indocker_timeout_error_container')
        end

        it 'raises Indocker::Errors::ContainerTimeoutError error if ready_block returns false' do
          expect{
            ioc.container_manager.start('indocker_timeout_error_container')
          }.to raise_error(Indocker::Errors::ContainerTimeoutError)
        end
      end

      context 'if ready reaches timeout' do
        before(:all) do
          Indocker.define_container 'indocker_timeout_reached_container' do
            use images.find_by_repo(:indocker_image)

            ready sleep: 0.1, timeout: 1 do
              sleep 2

              true
            end
          end

          ioc.container_manager.create('indocker_timeout_reached_container')
        end

        it 'raises Indocker::Errors::ContainerTimeoutError error if ready_block returns false' do
          expect{
            ioc.container_manager.start('indocker_timeout_reached_container')
          }.to raise_error(Indocker::Errors::ContainerTimeoutError)
        end
      end
    end

    context 'with container dependencies' do
      before(:all) do
        Indocker.define_container 'indocker_container_depends_on' do
          use images.find_by_repo(:indocker_image)

          depends_on containers.find_by_name('indocker_container')
        end

        ioc.container_manager.create('indocker_container_depends_on')
      end

      after(:all)  { ioc.docker_api.delete_container('indocker_container') }

      it 'starts dependency container before' do
        ioc.container_manager.start('indocker_container_depends_on')

        sleep 1 # wait when container stops

        expect(
          ioc.docker_api.get_container_state('indocker_container')
        ).to eq(Indocker::ContainerMetadata::States::EXITED)
      end
    end

    context 'with specified volume' do
      before(:all) do
        Indocker.define_volume 'indocker_volume'

        Indocker.define_container 'indocker_volume_container' do
          use images.find_by_repo(:indocker_image)
          mount volumes.find_by_name('indocker_volume'), to: '/app'
        end

        ioc.container_manager.create('indocker_volume_container')
        ioc.container_manager.start('indocker_volume_container')
      end

      after(:all) do
        ioc.docker_api.delete_container('indocker_volume_container')
        ioc.docker_api.delete_volume('indocker_volume')
      end

      it 'creates volume before start' do
        expect(
          ioc.docker_api.volume_exists?('indocker_volume')
        ).to be true
      end
    end

    context 'with specified network' do
      before(:all) do
        Indocker.define_network 'indocker_network'

        Indocker.define_container 'indocker_network_container' do
          use images.find_by_repo(:indocker_image)
          use networks.indocker_network
        end

        ioc.container_manager.create('indocker_network_container')
        ioc.container_manager.start('indocker_network_container')
      end

      after(:all) do
        ioc.container_manager.delete('indocker_network_container')
        ioc.docker_api.delete_network('indocker_network')
      end

      context 'creates network before start' do
        it 'for new network' do
          expect(
            ioc.docker_api.get_network_id('indocker_network')
          ).to match(/[\w\d]{64}/)

          expect(ioc.docker_api.network_exists?('indocker_network')).to be true
        end

        it 'if network already exists' do
          ioc.container_manager.stop('indocker_network_container')
          ioc.container_manager.start('indocker_network_container')

          expect(
            ioc.docker_api.get_network_id('indocker_network')
          ).to match(/[\w\d]{64}/)

          expect(ioc.docker_api.network_exists?('indocker_network')).to be true
        end
      end

      it 'connect container to specified network' do
        expect(
          ioc.docker_api.inspect_network('indocker_network')['Containers'].keys
        ).to include(
          ioc.docker_api.get_container_id('indocker_network_container')
        )
      end

      it 'starts container' do
        sleep 1 # wait when container stops

        expect(
          ioc.docker_api.get_container_state(
            ioc.docker_api.get_container_id('indocker_network_container')
          )
        ).to eq(Indocker::ContainerMetadata::States::EXITED)
      end
    end
  end

  describe '#copy' do
    let(:copy_to_path) { ioc.config.build_dir.join('indocker_list_container_files') }
    
    before(:all) do
      Indocker.define_image 'indocker_copy_image' do
        from 'alpine'

        run "mkdir -p /sample/deeper &&                 
        echo 'example1.txt' > /sample/example1.txt &&
        echo 'example3.txt' > /sample/deeper/example2.txt"
      end
      
      Indocker.define_container :indocker_copy_container do
        use images.find_by_repo('indocker_copy_image')
      end
      
      ioc.image_builder.build('indocker_copy_image')
      ioc.container_manager.create('indocker_copy_container')
    end

    it 'returns files list' do
      expect(
        ioc.container_manager.copy(
          name:      :indocker_copy_container,
          copy_from: '/sample/deeper',
          copy_to:   copy_to_path
        )
      ).to match(['deeper/example2.txt'])
    end

    it 'copies files to output path' do
      ioc.container_manager.copy(
        name:      :indocker_copy_container,
        copy_from: '/sample/.',
        copy_to:   copy_to_path
      )

      ensure_content(File.join(copy_to_path, 'example1.txt'), 'example1.txt')
      ensure_content(File.join(copy_to_path, 'deeper/example2.txt'), 'example3.txt')
    end

    it 'copies single file' do
      ioc.container_manager.copy(
        name:      :indocker_copy_container,
        copy_from: '/sample/example1.txt',
        copy_to:   copy_to_path
      )

      ensure_content(File.join(copy_to_path, 'example1.txt'), 'example1.txt')
    end
  end
end