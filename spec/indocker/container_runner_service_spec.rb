require 'spec_helper'

describe Indocker::ContainerRunnerService do
  subject { ioc.image_build_service }

  before do
    Indocker.image 'simple_image' do
      from 'hello-world'
    end

    Indocker.container 'simple_container', from: 'simple_image'

    subject.run('simple_container')
  end

  it 'runs container' do
    expect(
      ioc.docker_commands.container_exists?('simple_container')
    ).to be true
  end

  it 'updates container metadata with container_id' do
    expect(
      ioc.container_repository.get_container('simple_container').id
    ).to eq(ioc.docker_commands.get_container_id('simple_container'))
  end
end