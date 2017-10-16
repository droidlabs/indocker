require 'spec_helper'

describe Indocker::ContainerManager do
  subject { ioc.container_manager }

  describe '#create' do
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
      end
    
      it 'runs container' do
        subject.create('indocker_simple_container')
        
        expect(
          ioc.docker_api.container_exists?('indocker_simple_container')
        ).to be true
      end
    end
  end

  describe '#copy' do
    let(:copy_to_path) { File.expand_path File.join(__dir__, '../../tmp/indocker_list_container_files') }

    before do
      Indocker.define_image 'indocker_copy_image' do
        from 'alpine'

        run 'mkdir -p /sample'
        run 'mkdir -p /sample/deeper'
        run 'echo "example1.txt" > /sample/example1.txt'
        run 'echo "example2.txt" > /sample/example2.txt'
        run 'echo "example3.txt" > /sample/deeper/example3.txt'
        run 'echo "example4.txt" > /sample/deeper/example4.txt'

        cmd ['ls']
      end
      ioc.image_builder.build('indocker_copy_image')

      Indocker.define_container :indocker_copy_container do
        use images.indocker_copy_image
      end
    end

    it 'returns files list' do
      expect(
        subject.copy(
          name:      :indocker_copy_container, 
          copy_from: '/sample/deeper',
          copy_to:   copy_to_path
        )
      ).to match(
        [
          'deeper/example3.txt',
          'deeper/example4.txt'
        ]
      )
    end

    it 'copies files to output path' do
      subject.copy(
        name:      :indocker_copy_container, 
        copy_from: '/sample/.',
        copy_to:   copy_to_path
      )

      ensure_content(File.join(copy_to_path, 'example1.txt'), 'example1.txt')
      ensure_content(File.join(copy_to_path, 'example2.txt'), 'example2.txt')
      ensure_content(File.join(copy_to_path, 'deeper/example3.txt'), 'example3.txt')
      ensure_content(File.join(copy_to_path, 'deeper/example4.txt'), 'example4.txt')
    end
  end
end