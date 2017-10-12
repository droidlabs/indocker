require 'spec_helper'

describe 'Indocker::ImageBuilder' do
  subject { ioc.image_builder }

  context 'for image without dependencies' do
    before do
      Indocker.define_image('indocker_image') do
        before_build { 'test' }
        
        from 'hello-world'
        workdir '/'
      end

      subject.build('indocker_image')
    end

    it 'builds image without dependencies' do
      expect(
        ioc.docker_api.image_exists?('indocker_image')
      ).to be true
    end

    it 'updates image_metadata with image_id' do
      expect(
        ioc.image_metadata_repository.find_by_repo('indocker_image').image_id
      ).to eq(ioc.docker_api.get_image_id('indocker_image'))
    end

    it 'deletes build_path after image building' do
      image_metadata = ioc.image_metadata_repository.find_by_repo('indocker_image')

      expect(
        File.exists?(image_metadata.build_dir)
      ).to be false
    end
  end

  context 'for image with dependencies' do
    context 'circular dependencies' do
      before do
        Indocker.define_image('indocker_circular_image') do
          before_build do
            docker_cp 'circular_container'
          end
          
          from 'hello-world'
          workdir '/'
        end

        Indocker.define_container 'circular_container' do
          use images.indocker_circular_image
        end
      end

      it 'raises Indocker::Errors::CircularImageDependency' do
        expect{
          subject.build('indocker_circular_image')
        }.to raise_error(Indocker::Errors::CircularImageDependency)
      end
    end

    context 'for non circular dependencies' do
      before do
        Indocker.define_image('indocker_image') do          
          from 'alpine:latest'
          workdir '/'
          run 'echo "Hello World" > test.txt'
        end

        Indocker.define_image('indocker_image_with_dependency') do
          before_build do
            docker_cp 'container' do
              copy 'test.txt', 'test.txt'
            end
          end
          
          from 'alpine:latest'
          workdir '/'
          copy 'test.txt', 'test.txt'
        end

        Indocker.define_container 'container' do
          use images.indocker_image
        end
      end

      it 'builds image with dependency' do
        subject.build('indocker_image_with_dependency')
        
        expect(
          ioc.docker_api.image_exists?('indocker_image_with_dependency')
        ).to be true
      end
  
      it 'updates image_metadata with image_id' do
        subject.build('indocker_image_with_dependency')

        expect(
          ioc.image_metadata_repository.find_by_repo('indocker_image_with_dependency').image_id
        ).to eq(ioc.docker_api.get_image_id('indocker_image_with_dependency'))
      end
    end
  end

  context 'for not existing image' do
    it 'raises Indocker::Errors::ImageIsNotDefined' do
      expect{
        subject.build('indocker_image_without_dependencies')
      }.to raise_error(Indocker::Errors::ImageIsNotDefined)
    end
  end
end