class Indocker::ContainerBuilder
  include SmartIoC::Iocify
  
  bean :container_builder

  inject :container_metadata_repository
  inject :envs_loader
  inject :config

  def build(name)
    container_metadata = container_metadata_repository.get_by_name(name)
        
    env_metadata = container_metadata.env_files.inject(Indocker::Envs::EnvMetadata.new) do |all, path|
      all += envs_loader.parse(path)
    end

    Indocker::DockerAPI::ContainerConfig.new(
      name:          name, 
      repo:          container_metadata.repo, 
      tag:           container_metadata.tag,
      exposed_ports: container_metadata.exposed_ports,
      port_bindings: container_metadata.port_bindings,
      cmd:           container_metadata.command,
      volumes:       container_metadata.volumes,
      binds:         container_metadata.binds,
      env:           env_metadata.to_array + container_metadata.envs
    )
  end
end