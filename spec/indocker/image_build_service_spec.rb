require 'spec_helper'

describe Indocker::ImageBuildService do
  subject { described_class.new }

  let(:docker)           { Indocker::DockerCommands.new }
  let(:image_repository) { Indocker.images }
  let(:image_name)       { 'simple_image' }

  before do
    Indocker.image(image_name) { from 'hello-world' }

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
end