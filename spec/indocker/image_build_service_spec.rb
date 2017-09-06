require 'spec_helper'

describe Indocker::ImageBuildService do
  subject { described_class.new }

  let(:docker)            { Indocker::DockerCommands.new }
  let(:image_repository)  { Indocker.images }
  let(:image_name)        { 'simple_image' }
  let(:before_build_flag) { '' }

  before do
    Indocker.image(image_name) do
       before_build { 'test' }
       
       from 'hello-world'
    end

    subject.build(image_name)
  end

  it 'builds simple image' do
    expect(
      docker.image_exists?(image_name)
    ).to be true
  end

  it 'updates image_metadata with image_id' do
    expect(
      image_repository.detect {|image| image.name == image_name}.id
    ).to eq(docker.get_image_id('simple_image'))
  end

  it 'runs before_build block for image' do
    expect(subject).to receive(:prepare_image).and_return('test')

    subject.build(image_name)
  end
end