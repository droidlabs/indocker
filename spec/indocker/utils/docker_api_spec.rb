require 'spec_helper'

describe Indocker::DockerApi do
  subject { ioc.docker_api }

  describe '#get_image_id' do
    context 'if image presents' do
      it 'returns instance of Docker::Image class' do
        expect(subject.get_image_id('alpine')).to be_a(String)
      end
    end

    context 'if image does not present' do
      it 'returns nil ' do
        expect(subject.get_image_id('some-invalid-image')).to be_nil
      end
    end
  end

  describe '#find_container_by_name' do
    context 'if container presents' do
      let!(:container) { Docker::Container.create('Image' => 'alpine:latest', 'name': 'alpine') }
      after { container.delete(force: true) }

      it 'returns instance of Docker::Container class' do
        expect(subject.find_container_by_name('alpine')).to be_a(Docker::Container)
      end
    end

    context 'if container does not present' do
      it 'returns nil' do
        expect(subject.find_container_by_name('invalid-container-name')).to be_nil
      end
    end
  end
end