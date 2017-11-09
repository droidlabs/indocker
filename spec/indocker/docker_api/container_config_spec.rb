require 'spec_helper'

describe Indocker::DockerAPI::ContainerConfig do
  let(:params_hash) {
    {
      repo:          'indocker_image', 
      tag:           'latest',
      image:         'indocker_another_image:latest',
      name:          'indocker_container', 
      cmd:           ['/bin/bash'], 
      volumes:       ['tmp', 'gems_volume'], 
      exposed_ports: ['2000', '4000'], 
      env:           'RUBY_ENV=development RAILS_ENV=development',
      binds: [
        { name: 'tmp',         to: '/tmp' },
        { name: 'gems_volume', to: '/bundle' }
      ], 
      port_bindings: [{
        container_port: '2000',
        host_port:      '3000'
      }]
    }
  }

  

  describe '#to_hash' do
    it 'returns hash with valid params' do
      expect(
        described_class.new(params_hash).to_hash
      ).to match(
        {
          'Image'        => 'indocker_another_image:latest',
          'name'         => 'indocker_container',
          'Cmd'          => ['/bin/bash'],
          'Env'          => 'RUBY_ENV=development RAILS_ENV=development',
          'Tty'          => true,
          'OpenStdin'    => true,
          'StdinOnce'    => true,
          'AttachStdin'  => true,
          'AttachStdout' => true,
          'ExposedPorts' => { 
            '2000' => {}, 
            '4000' => {} 
          },
          'Volumes' => {
            'tmp'         => {},
            'gems_volume' => {}
          },
          'HostConfig' => {
            'Binds'        => ['tmp:/tmp', 'gems_volume:/bundle'],
            'PortBindings' => {
              '2000' => [
                {
                  'HostPort' => '3000'
                }
              ]
            }
          }
        }
      )
    end
  end
end