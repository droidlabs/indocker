require 'spec_helper'

describe 'Indocker::ImageBuilder' do
  context 'for image without dependencies' do
    before(:all) do
      Indocker.define_image('indocker_image') do
        from 'hello-world'
        workdir '/'
      end

      ioc.image_builder.build('indocker_image')
    end

    after(:all) { truncate_docker_items }

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
    context 'circular docker_cp dependency' do
      before do
        Indocker.define_image('indocker_image') do
          before_build do
            docker_cp 'indocker_container'
          end
          
          from 'hello-world'
          workdir '/'
        end

        Indocker.define_container 'indocker_container' do
          use images.find_by_repo(:indocker_image)
        end
      end

      after(:all) { truncate_docker_items }

      it 'raises Indocker::Errors::CircularImageDependency' do
        expect{
          ioc.image_builder.build('indocker_image')
        }.to raise_error(Indocker::Errors::CircularImageDependency)
      end
    end

    context 'for non circular docker_cp dependency' do
      before do
        Indocker.define_image('indocker_dependency_image') do          
          from 'alpine:latest'
          workdir '/'
          run 'echo "Hello World" > test.txt'
        end

        Indocker.define_image('indocker_image') do
          before_build do
            docker_cp 'indocker_container' do
              copy 'test.txt' => '/copy' 
            end
          end
          
          from :indocker_dependency_image, tag: :latest
          workdir '/'
          copy '/copy/test.txt' => '/'
        end

        Indocker.define_container 'indocker_container' do
          use images.find_by_repo(:indocker_dependency_image)
        end

        ioc.image_builder.build('indocker_image')
      end

      after(:all) { truncate_docker_items }

      it 'builds image with dependency' do
        expect(
          ioc.docker_api.image_exists?('indocker_image')
        ).to be true
      end
    end
  end

  context 'for not existing image' do
    it 'raises Indocker::Errors::ImageIsNotDefined' do
      expect{
        ioc.image_builder.build('indocker_image')
      }.to raise_error(Indocker::Errors::ImageIsNotDefined)
    end
  end

  context 'when push image to registry' do
    before do
      Indocker.define_image('indocker_image') do
        from 'alpine:latest'
        
        use registry.localhost(push: true)
      end

      ioc.image_builder.build('indocker_image')
    end

    it 'tags image with specified registry_repo_tag' do
      expect(
        ioc.docker_api.image_exists?('localhost:5000/indocker_image')
      ).to be true
    end

    it 'pushes image to registry' do
      ioc.docker_api.delete_image('indocker_image')

      ioc.docker_api.pull('fromImage' => 'localhost:5000/indocker_image:latest')

      expect(
        ioc.docker_api.image_exists?('localhost:5000/indocker_image')
      ).to be true
    end

    after(:all) do 
      truncate_docker_items
    end
  end

  context 'with coping files from project_root' do
    before do
      Indocker.define_image('indocker_image') do          
        from 'alpine:latest'

        copy File.join(__dir__, '../../example/assets/.') => 'assets'
      end
    end

    after(:all) { truncate_docker_items }

    it 'does not raise error' do
      expect{
        ioc.image_builder.build('indocker_image')
      }.to_not raise_error
    end
  end
end