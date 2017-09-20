require 'spec_helper'

describe 'Indocker::ImageBuildService' do
  subject { ioc.image_build_service }

  context 'for image without dependencies' do
    before do
      Indocker.image('indocker_image_without_dependencies') do
        before_build { 'test' }
        
        from 'hello-world'
      end

      subject.build('indocker_image_without_dependencies')
    end

    it 'builds image_without_dependencies' do
      expect(
        ioc.docker_api.image_exists_by_repo?('indocker_image_without_dependencies')
      ).to be true
    end

    it 'updates image_metadata with image_id' do
      expect(
        ioc.image_repository.find_by_repo('indocker_image_without_dependencies').id
      ).to eq(ioc.docker_api.find_image_by_repo('indocker_image_without_dependencies').id)
    end

    it 'runs before_build block for image' do
      expect_any_instance_of(Indocker::ImagePrepareService).to receive(:prepare).and_return('test')

      subject.build('indocker_image_without_dependencies')
    end

    it 'deletes build_path after image building' do
      image_metadata = ioc.image_repository.find_by_repo('indocker_image_without_dependencies')

      expect(
        File.exists?(image_metadata.build_dir)
      ).to be false
    end
  end

  context 'for image with dependencies' do
    context 'circular dependencies' do
      before do
        Indocker.image('indocker_image_with_circular_dependency') do
          before_build { run_container 'indocker_container_with_circular_dependency' }
          
          from 'hello-world'
        end

        Indocker.container 'indocker_container_with_circular_dependency', from_repo: 'indocker_image_with_circular_dependency'
      end

      it 'raises Indocker::Errors::CircularImageDependency' do
        expect{
          subject.build('indocker_image_with_circular_dependency')
        }.to raise_error(Indocker::Errors::CircularImageDependency)
      end
    end

    context 'for non circular dependencies' do
      before do
        Indocker.image('indocker_image_for_container') do          
          from 'hello-world'
        end

        Indocker.image('indocker_image_with_dependency') do
          before_build { run_container 'indocker_simple_container' }
          
          from 'hello-world'
        end

        Indocker.container 'indocker_simple_container', from_repo: 'indocker_image_for_container'
        
        subject.build('indocker_image_with_dependency')
      end

      it 'builds indocker_image_with_dependency' do
        expect(
          ioc.docker_api.image_exists_by_repo?('indocker_image_with_dependency')
        ).to be true
      end
  
      it 'updates image_metadata with image_id' do
        expect(
          ioc.image_repository.find_by_repo('indocker_image_with_dependency').id
        ).to eq(ioc.docker_api.find_image_by_repo('indocker_image_with_dependency').id)
      end
  
      it 'runs before_build block for image' do
        expect(
          ioc.container_repository.get_container('indocker_simple_container').id
        ).to eq(ioc.docker_api.find_container_by_name('indocker_simple_container').id)
      end
    end
  end

  context 'for not existing image' do
    it 'raises Indocker::Errors::ImageDoesNotDefined' do
      expect{
        subject.build('indocker_image_without_dependencies')
      }.to raise_error(Indocker::Errors::ImageDoesNotDefined)
    end
  end
end