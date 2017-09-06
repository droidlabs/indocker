require 'spec_helper'

describe Indocker::ContainerRunnerService do
  subject { described_class.new }

  let(:docker)               { Indocker::DockerCommands.new }
  let(:container_repository) { Indocker.containers }
  let(:container_name)       { 'simple_container' }

  before do
    Indocker.image 'simple_image' do
      from 'hello-world'
    end

    Indocker.container 'simple_container', from: 'simple_image'

    subject.run('simple_container', 'simple_image')
  end

  it 'runs container' do
    expect(
      docker.container_exists?('simple_container')
    ).to be true
  end

  it 'updates container metadata with container_id' do
    expect(
      container_repository.detect { |container| container.name == container_name }.id
    ).to eq(docker.get_container_id(container_name))
  end
end