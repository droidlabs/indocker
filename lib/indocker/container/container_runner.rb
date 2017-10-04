class Indocker::ContainerRunner
  include SmartIoC::Iocify
  
  bean   :container_runner

  inject :container_metadata_repository
  inject :image_builder
  inject :docker_api

  def create(container_name)
    container_metadata = container_metadata_repository.get_container(container_name)
    
    if !docker_api.image_exists_by_repo?(container_metadata.repo, tag: container_metadata.tag)
      image_builder.build(container_metadata.repo, tag: container_metadata.tag)
    end

    container = docker_api.create_container(container_metadata)
    
    container_metadata.container_id = container.id

    container
  end
end