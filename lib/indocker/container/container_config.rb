class Indocker::ContainerConfig
  include Indocker::ImageHelper

  attr_reader :state

  def initialize(repo:, tag: nil, image:, 
                 name: nil, cmd: nil, env: nil, volumes: {}, binds: [], 
                 exposed_ports: nil, port_bindings: nil)
    @state = {
      'Image'          => @image || full_name(@repo, @tag),
      'name'           => name.to_s,
      'Cmd'            => cmd,
      'Env'            => env,
      'ExposedPorts'   => exposed_ports,
      'Tty'            => true,
      'OpenStdin'      => true,
      'StdinOnce'      => true,
      'AttachStdin'    => true,
      'AttachStdout'   => true,
      'HostConfig' => {
        'PortBindings' => port_bindings,
        'Binds'        => binds
      },
      'Volumes' => {'/bundle_path' => {}}
    }.delete_if { |_, value| value.to_s.empty? }
  end

  def ==(other)
    self.state == other.state
  end
end