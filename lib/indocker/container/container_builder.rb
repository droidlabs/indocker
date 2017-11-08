class Indocker::ContainerBuilder
  include SmartIoC::Iocify
  
  bean :container_builder

  inject :container_repository
  inject :envs_loader

  def build(name)
    container_metadata = container_metadata_repository.get_by_name(name)

    env_metadata = container_metadata.env_files
      .map {|path| envs_loader.parse(config.root.join(path))}
      .inject(Indocker::Envs::EnvMetadata.new) {|sum, env| sum += env}

    Indocker::ContainerConfig.new(
      name:          name, 
      repo:          container_metadata.repo, 
      tag:           container_metadata.tag,
      exposed_ports: container_metadata.exposed_ports,
      port_bindings: container_metadata.port_bindings,
      env:           env_metadata.to_array,
      command:       container_metadata.command,
      volumes:       container_metadata.volumes,
      binds:         container_metadata.binds
    )
  end
end