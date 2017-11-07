class Indocker::ContainerInspector
  include SmartIoC::Iocify

  bean :container_inspector

  inject :docker_api

  def inspect(name)
    info = docker_api.inspect_container(name)

    params = {
      'Image'          => info['Image'],
      'name'           => info['Name'],
      'Cmd'            => info['Args'],
      'Env'            => info['Config']['Env'],
      'Network'        => 
      'ExposedPorts'   => exposed_ports,
      'Tty'            => true,
      'OpenStdin'      => true,
      'StdinOnce'      => true,
      'AttachStdin'    => true,
      'AttachStdout'   => true,
      'HostConfig' => {
        'PortBindings' => port_bindings
      },
      'Volumes' => {'/bundle_path' => {}}
    }.delete_if { |_, value| value.to_s.empty? }
  end

  def check_params
    
  end
end