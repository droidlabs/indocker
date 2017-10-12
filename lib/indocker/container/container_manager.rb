class Indocker::ContainerManager
  include SmartIoC::Iocify
  
  bean   :container_manager

  inject :container_metadata_repository
  inject :image_metadata_repository
  inject :docker_api
  inject :logger

  def create(name)
    container_metadata = container_metadata_repository.get_by_name(name)
    
    container_id = docker_api.create_container(
      name: name, 
      repo: container_metadata.repo, 
      tag: container_metadata.tag
    )

    logger.info "Successfully created container :#{name}"

    container_id
  end

  def start(name)
    container_id = docker_api.start_container(name)

    logger.info "Successfully started container :#{name}"

    container_id
  rescue Docker::Error::ClientError => e
    logger.error "The following error occured when starting :#{name} container"
    logger.error e.message
  end

  def stop(name)
    container_id = docker_api.stop_container(name)

    logger.info "Successfully stopped container :#{name}"

    container_id
  end

  def delete(name)
    container_id = docker_api.delete_container(name)

    logger.info "Successfully deleted container :#{name}"

    container_id
  end
end