require 'spec_helper'

describe Indocker::ImageDependenciesManager do
  subject { ioc.image_dependencies_manager }

  context '#check_circular_dependencies!' do
    before(:all) do
      Indocker.define_image :base_image do
        from 'ruby-alpine:latest'
      end
    end

    context 'with valid params' do
      let(:image_metadata) { ioc.image_metadata_repository.find_by_repo(:valid_image) }

      before(:all) do
        Indocker.define_image :helper_image do
          from :base_image
        end

        Indocker.define_container :helper_container do
          use images.find_by_repo(:helper_image)
        end

        Indocker.define_image :valid_image do
          from :base_image

          before_build do
            docker_cp :helper_container do
              copy '.' => '.'
            end
          end
        end
      end

      it 'not raises error' do
        expect{
          subject.check_circular_dependencies!(image_metadata)
        }.to_not raise_error
      end
    end

    context 'with circular dependency' do
      it 'raises Indocker::Errors::CircularImageDependency if has FROM circular dependency' do
        Indocker.define_image :circular_image_base do
          from :circular_image_children
        end

        Indocker.define_image :circular_image_children do
          from :circular_image_base
        end

        expect{
          subject.check_circular_dependencies!(ioc.image_metadata_repository.find_by_repo(:circular_image_children))
        }.to raise_error(Indocker::Errors::CircularImageDependency)
      end

      it 'raises Indocker::Errors::CircularImageDependency if has DOCKER_CP circular dependency' do
        Indocker.define_image :circular_container_base do
          from :base_image

          before_build do
            docker_cp :circular_container_children do
              copy '.' => '.'
            end
          end
        end

        Indocker.define_image :circular_container_children do
          from :circular_container_base
        end

        Indocker.define_container :container_childer do
          use images.find_by_repo(:circular_container_children)
        end

        expect{
          subject.check_circular_dependencies!(ioc.image_metadata_repository.find_by_repo(:circular_image_children))
        }.to raise_error(Indocker::Errors::CircularImageDependency)
      end
    end
  end
end