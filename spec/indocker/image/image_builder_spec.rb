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
          cmd '/bin/bash'
        end

        Indocker.define_image('indocker_image_with_dependency') do
          before_build do
            docker_cp 'indocker_container' do
              copy 'test.txt' => build_dir
            end
          end
          
          from 'alpine:latest'
          workdir '/'
          copy do
            { 'test.txt' => '/' }
          end
        end

        Indocker.define_container 'indocker_container' do
          use images.indocker_image
        end
      end

      it 'builds image with dependency' do
        subject.build('indocker_image_with_dependency')
        
        expect(
          ioc.docker_api.image_exists?('indocker_image_with_dependency')
        ).to be true
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

  context 'with coping files from project_root' do
    before do
      Indocker.define_image('indocker_copy_image') do          
        from 'alpine:latest'

        copy root: ioc.config.root do
          { 'assets/.' => 'assets' }
        end
      end
    end

    it 'does not raise error' do
      expect{
        subject.build('indocker_copy_image')
      }.to_not raise_error
    end
  end
end