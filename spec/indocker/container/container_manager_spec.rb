require 'spec_helper'

describe Indocker::ContainerManager do
  let(:container_manager) { ioc.container_manager }
  let(:docker_api)        { ioc.docker_api }

  describe '#create' do
    context 'for existing image' do
      before do
        Indocker.define_image 'indocker_simple_image' do
          from 'hello-world' 
          
          workdir '.'
        end

        Indocker.define_container 'indocker_simple_container' do
          use images.indocker_simple_image
        end

        ioc.image_builder.build('indocker_simple_image')
      end
    
      it 'runs container' do
        container_manager.create('indocker_simple_container')
        
        expect(
          ioc.docker_api.container_exists?('indocker_simple_container')
        ).to be true
      end
    end
  end

  describe '#start' do
    context 'with container dependencies' do
      let(:main_container_id)      { docker_api.get_container_id('indocker_main_container') }
      let(:dependecy_container_id) { docker_api.get_container_id('indocker_dependency_container') }

      before do
        Indocker.define_image 'indocker_main_container' do
          from 'alpine:latest' 
          workdir '.'
          cmd ['/bin/sh']
        end

        Indocker.define_image 'indocker_dependency_container' do
          from 'alpine:latest' 
          workdir '.'
          cmd ['/bin/sh']
        end

        Indocker.define_container 'indocker_dependency_container' do
          use images.indocker_dependency_container
        end

        Indocker.define_container 'indocker_main_container' do
          use images.indocker_main_container
          
          depends_on containers.get_by_name('indocker_dependency_container')
        end


        ioc.image_builder.build('indocker_main_container')
        ioc.image_builder.build('indocker_dependency_container')
        ioc.container_manager.create('indocker_main_container')

        container_manager.start('indocker_main_container')
      end

      after do
        container_manager.stop('indocker_main_container')
        container_manager.delete('indocker_main_container')
        container_manager.stop('indocker_dependency_container')
        container_manager.delete('indocker_dependency_container')
      end

      it 'runs dependency container before' do
        expect(
          docker_api.get_container_state('indocker_dependency_container')
        ).to eq(Indocker::ContainerMetadata::States::EXITED)
      end
    end

    context 'with specified network' do
      let(:container_id) { docker_api.get_container_id('indocker_simple_container') }
      let(:network_id)   { docker_api.get_network_id('indocker_network') }

      before do
        Indocker.define_image 'indocker_simple_image' do
          from 'hello-world' 
          
          workdir '.'
        end

        Indocker.define_network 'indocker_network'

        Indocker.define_container 'indocker_simple_container' do
          use images.indocker_simple_image
          use networks.indocker_network
        end

        ioc.image_builder.build('indocker_simple_image')
        ioc.container_manager.create('indocker_simple_container')

        container_manager.start('indocker_simple_container')
      end

      after do
        container_manager.stop('indocker_simple_container')
        container_manager.delete('indocker_simple_container')
        docker_api.remove_network('indocker_network')
      end
      
      context 'creates network before start' do
        it 'for new network' do
          expect(network_id).to match(/[\w\d]{64}/)
          expect(docker_api.network_exists?('indocker_network')).to be true
        end

        it 'if network already exists' do
          container_manager.stop('indocker_simple_container')
          container_manager.start('indocker_simple_container')

          expect(network_id).to match(/[\w\d]{64}/)
          expect(docker_api.network_exists?('indocker_network')).to be true
        end
      end

      it 'connect container to specified network' do
        expect(
          docker_api.inspect_network(network_id)['Containers'].keys
        ).to include(container_id)
      end

      it 'starts container' do
        expect(
          docker_api.get_container_state(container_id)
        ).to eq(Indocker::ContainerMetadata::States::RUNNING)
      end
    end
  end

  describe '#copy' do
    let(:copy_to_path) { File.expand_path File.join(__dir__, '../../tmp/indocker_list_container_files') }

    before do
      Indocker.define_image 'indocker_copy_image' do
        from 'alpine'

        run 'mkdir -p /sample'
        run 'mkdir -p /sample/deeper'
        run 'echo "example1.txt" > /sample/example1.txt'
        run 'echo "example2.txt" > /sample/example2.txt'
        run 'echo "example3.txt" > /sample/deeper/example3.txt'
        run 'echo "example4.txt" > /sample/deeper/example4.txt'

        cmd ['ls']
      end
      ioc.image_builder.build('indocker_copy_image')

      Indocker.define_container :indocker_copy_container do
        use images.indocker_copy_image
      end
    end

    it 'returns files list' do
      expect(
        container_manager.copy(
          name:      :indocker_copy_container, 
          copy_from: '/sample/deeper',
          copy_to:   copy_to_path
        )
      ).to match(
        [
          'deeper/example3.txt',
          'deeper/example4.txt'
        ]
      )
    end

    it 'copies files to output path' do
      container_manager.copy(
        name:      :indocker_copy_container, 
        copy_from: '/sample/.',
        copy_to:   copy_to_path
      )

      ensure_content(File.join(copy_to_path, 'example1.txt'), 'example1.txt')
      ensure_content(File.join(copy_to_path, 'example2.txt'), 'example2.txt')
      ensure_content(File.join(copy_to_path, 'deeper/example3.txt'), 'example3.txt')
      ensure_content(File.join(copy_to_path, 'deeper/example4.txt'), 'example4.txt')
    end
  end
end