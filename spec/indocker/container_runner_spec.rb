require 'spec_helper'

describe Indocker::ContainerRunner do
  subject { ioc.container_runner }

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
      subject.create('indocker_simple_container')
    end
  
    it 'runs container' do
      expect(
        ioc.docker_api.container_exists_by_name?('indocker_simple_container')
      ).to be true
    end

    it 'updates container metadata with container_id' do
      expect(
        ioc.container_metadata_repository.get_container('indocker_simple_container').container_id
      ).to eq(ioc.docker_api.find_container_by_name('indocker_simple_container').id)
    end
  end
end