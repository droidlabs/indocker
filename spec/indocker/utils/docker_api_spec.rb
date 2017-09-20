require 'spec_helper'

describe Indocker::DockerApi do
  subject { ioc.docker_api }
  
  before(:all) do
    unless ioc.docker_api.image_exists_by_repo?('hello-world')
      ioc.docker_api.pull('fromImage' => 'hello-world')
    end
  end

  describe '#find_image_by_repo' do
    context 'if image presents' do
      it 'returns instance of Docker::Image class' do
        expect(subject.find_image_by_repo('hello-world')).to be_a(Docker::Image)
      end
    end

    context 'if image does not present' do
      it 'returns nil ' do
        expect(subject.find_image_by_repo('some-invalid-image')).to be_nil
      end
    end
  end

  describe '#find_container_by_name' do
    context 'if container presents' do
      let!(:container) { Docker::Container.create('Image' => 'hello-world', 'name': 'hello-world') }
      after { container.delete(force: true) }

      it 'returns instance of Docker::Container class' do
        expect(subject.find_container_by_name('hello-world')).to be_a(Docker::Container)
      end
    end

    context 'if container does not present' do
      it 'returns nil' do
        expect(subject.find_container_by_name('invalid-container-name')).to be_nil
      end
    end
  end

  describe '#find_container_by_id' do
    context 'if container presents' do
      let!(:container) { Docker::Container.create('Image' => 'hello-world', 'name': 'hello-world') }
      after { container.delete(force: true) }

      it 'returns instance of Docker::Container class' do
        expect(subject.find_container_by_id(container.id)).to be_a(Docker::Container)
      end
    end

    context 'if container does not present' do
      it 'returns nil' do
        expect(subject.find_container_by_id('invalid-container-name')).to be_nil
      end
    end
  end
end