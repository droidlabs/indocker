require 'spec_helper'

# TODO: rename to ContainerConfigBuilder
describe Indocker::ContainerBuilder do
  describe '#build' do
    subject { ioc.container_builder }
    
    before(:all) do
      Indocker.define_image :indocker_image do
        from 'ruby:2.3.1'
        workdir '/app'
        cmd 'ls'
      end

      Indocker.define_network :indocker_network
      Indocker.define_volume  :indocker_volume

      Indocker.define_container :indocker_container do
        use images.find_by_repo(:indocker_image, tag: :latest)
        use networks.find_by_name(:indocker_network)
        
        mount volumes.find_by_name(:indocker_volume), to: '/tmp'

        env_file File.join(__dir__, '../../fixtures/spec.env')
        ports '2000:3000'
        cmd  '/bin/bash'
      end
    end

    after(:all) { truncate_docker_items }

    it 'returns instance of Indocker::DockerAPI::ContainerConfig' do
      expect(
        subject.build(:indocker_container)
      ).to be_a(Indocker::DockerAPI::ContainerConfig)
    end

    it 'returns config with valid params' do
      result = subject.build(:indocker_container)
      
      expect(result.image).to eq('indocker_image:latest')
      expect(result.name).to  eq(:indocker_container)
      expect(result.cmd).to   eq('/bin/bash')
      expect(result.env).to   eq('RUBY_ENV=development RAILS_ENV=development')

      expect(result.exposed_ports).to be_a(Indocker::DockerAPI::ContainerConfig::ExposedPortsConfig)
      expect(result.exposed_ports.ports).to eq(['2000'])

      expect(result.host_config).to be_a(Indocker::DockerAPI::ContainerConfig::HostConfig)
      expect(result.host_config.port_bindings).to match([
        {
          container_port: '2000',
          host_port:      '3000'
        }
      ])
      expect(result.host_config.binds).to match([
        {
          name: 'indocker_volume',
          to:   '/tmp'
        }
      ])

      expect(result.volumes_config).to be_a(Indocker::DockerAPI::ContainerConfig::VolumesConfig)
      expect(result.volumes_config.volumes).to eq(['/indocker_volume'])
    end
  end
end