require 'spec_helper'

describe Indocker::ContainerRunnerService do
  subject { ioc.container_runner_service }

  context 'for existing image' do
    before do
      Indocker.define_image 'indocker_simple_image' do
        from 'hello-world' 
        workdir '.'
      end
      ioc.image_build_service.build('indocker_simple_image')
  
      Indocker.define_container 'indocker_simple_container', from_repo: 'indocker_simple_image'
      subject.run('indocker_simple_container')
    end
  
    it 'runs container' do
      expect(
        ioc.docker_api.container_exists_by_name?('indocker_simple_container')
      ).to be true
    end

    it 'updates container metadata with container_id' do
      expect(
        ioc.container_repository.get_container('indocker_simple_container').id
      ).to eq(ioc.docker_api.find_container_by_name('indocker_simple_container').id)
    end
  end

  context 'for non existing image' do
    before do
      Indocker.define_container 'indocker_simple_container', from_repo: 'invalid_image'
    end

    it 'raises Indocker::Errors::ImageIsNotDefined error' do
      expect{
        subject.run('indocker_simple_container')
      }.to raise_error(Indocker::Errors::ImageIsNotDefined)
    end
  end
end