require 'spec_helper'

describe Indocker::DockerApi do
  let(:docker_api) { ioc.docker_api }

  describe '#create_network' do
    context 'simple network' do
      let!(:id) { docker_api.create_network('indocker') }

      after { docker_api.remove_network(id) }

      it 'creates network' do
        expect(
          docker_api.get_network_id('indocker')
        ).to eq(id)
      end
    end
  end

  describe '#add_container_to_network' do
    let(:container_id) { 
      docker_api.create_container(
        repo:    'alpine',
        tag:     'latest',
        name:    'indocker_alpine_container',
        command: %w(tail -F -n0 /etc/hosts)
      ) 
    }

    let(:network_id) { docker_api.create_network('indocker') }

    after do
      docker_api.stop_container(container_id)
      docker_api.delete_container(container_id)
      docker_api.remove_network(network_id)
    end

    it 'do something' do
      docker_api.add_container_to_network(
        network_name:   network_id,
        container_name: container_id
      )
        
      docker_api.start_container(container_id)

      expect(
        docker_api.inspect_network(network_id)['Containers'].keys
      ).to include(container_id)
    end
  end

  describe '#get_image_id' do
    context 'if image presents' do
      it 'returns instance of Docker::Image class' do
        expect(docker_api.get_image_id('alpine')).to be_a(String)
      end
    end

    context 'if image does not present' do
      it 'returns nil ' do
        expect(docker_api.get_image_id('some-invalid-image')).to eq(nil)
      end
    end
  end

  describe '#create_volume' do
    context 'simple volume' do
      let!(:id) { docker_api.create_volume('volume') }
      
      after { docker_api.remove_volume(id) }
      
      it 'creates volume' do
          expect(
              docker_api.get_volume_id('volume')
            ).to eq(id)
        end

    end
  end

  describe '#get_container_id' do
    context 'if container presents' do
      let!(:container) { Docker::Container.create('Image' => 'alpine:latest', 'name': 'alpine') }
      after { container.delete(force: true) }

      it 'returns container_id string' do
        expect(docker_api.get_container_id('alpine')).to be_a(String)
        expect(docker_api.get_container_id('alpine').size).to eq(64)
      end
    end

    context 'if container does not present' do
      it 'returns nil' do
        expect(docker_api.get_container_id('invalid-container-name')).to eq(nil)
      end
    end
  end
end