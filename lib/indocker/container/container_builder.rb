class Indocker::ContainerBuilder
  include SmartIoC::Iocify
  
  bean :container_builder

  inject :container_repository
  inject :envs_loader
  inject :config

  def build(name)
    container_metadata = container_metadata_repository.get_by_name(name)

    Indocker::ContainerConfig.new(
      name:          name, 
      repo:          container_metadata.repo, 
      tag:           container_metadata.tag,
      exposed_ports: container_metadata.exposed_ports,
      port_bindings: container_metadata.port_bindings,
      # env:           env_metadata.to_array,
      command:       container_metadata.command,
      volumes:       container_metadata.volumes,
      binds:         container_metadata.binds
    )
  end
end