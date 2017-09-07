require 'spec_helper'

describe Indocker::ImageBuildService do
  subject { described_class.new }

  let(:docker)                { Indocker::DockerCommands.new }
  let(:image_repository)      { Indocker.images }
  let(:container_repository)  { Indocker.containers }
  let(:before_build_flag)     { '' }

  context 'for not existing image' do
    it 'raises Indocker::Errors::ImageDoesNotDefined' do
      expect{
        subject.build('image_without_dependencies')
      }.to raise_error(Indocker::Errors::ImageDoesNotDefined)
    end
  end

  context 'for image without dependencies' do
    before do
      Indocker.image('image_without_dependencies') do
        before_build { 'test' }
        
        from 'hello-world'
      end

      subject.build('image_without_dependencies')
    end

    it 'builds image_without_dependencies' do
      expect(
        docker.image_exists?('image_without_dependencies')
      ).to be true
    end

    it 'updates image_metadata with image_id' do
      expect(
        image_repository.detect {|image| image.name == 'image_without_dependencies'}.id
      ).to eq(docker.get_image_id('image_without_dependencies'))
    end

    it 'runs before_build block for image' do
      expect(subject).to receive(:prepare_image).and_return('test')

      subject.build('image_without_dependencies')
    end
  end

  context 'for image with dependencies' do
    context 'circular dependencies' do
      before do
        Indocker.image('image_with_circular_dependency') do
          before_build { run_container 'container_with_circular_dependency' }
          
          from 'hello-world'
        end

        Indocker.container 'container_with_circular_dependency', from: 'image_with_circular_dependency'
      end

      it 'raises Indocker::Errors::ImageForContainerDoesNotExist' do
        expect{
          subject.build('image_with_circular_dependency')
        }.to raise_error(Indocker::Errors::ImageForContainerDoesNotExist)
      end
    end

    context 'for non circular dependencies' do
      before do
        Indocker.image('image_for_container') do          
          from 'hello-world'
        end

        Indocker.image('image_with_dependency') do
          before_build { run_container 'simple_container' }
          
          from 'hello-world'
        end

        Indocker.container 'simple_container', from: 'image_for_container'
      end

      it 'not raises error' do
        expect{
          subject.build('image_with_dependency')
        }.to_not raise_error
      end

      it 'builds image_with_dependency' do
        expect(
          docker.image_exists?('image_with_dependency')
        ).to be true
      end
  
      it 'updates image_metadata with image_id' do
        expect(
          image_repository.detect {|image| image.name == 'image_with_dependency'}.id
        ).to eq(docker.get_image_id('image_with_dependency'))
      end
  
      it 'runs before_build block for image' do
        expect(
          container_repository.detect { |container| container.name == 'simple_container' }.id
        ).to eq(docker.get_container_id('simple_container'))
      end
    end
  end
end