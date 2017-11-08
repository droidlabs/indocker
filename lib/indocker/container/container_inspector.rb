class Indocker::ContainerInspector
  include SmartIoC::Iocify

  bean :container_inspector

  inject :container_builder

  def changed?(name)
    container_config = docker_api.inspect_container(name)[Config]
    host_config      = docker_api.inspect_container(name)[HostConfig]

    inspected_config = Indocker::ContainerConfig.new(
      image:         container_config['Image'], 
      cmd:           container_config['Cmd'], 
      env:           container_config['Env'], 
      volumes:       container_config['Volumes'], 
      binds:         host_config['Binds'], 
      exposed_ports: container_config['ExposedPorts'], 
      port_bindings: host_config['PortBindings']
    )

    metadata_config = container_builder.build(name)

    inspected_config == metadata_config
  end
end