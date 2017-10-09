class Indocker::ContainerRunner
  include SmartIoC::Iocify
  
  bean   :container_runner

  inject :container_metadata_repository
  inject :image_metadata_repository
  inject :docker_api

  def create(container_name)
    container_metadata = container_metadata_repository.get_container(container_name)
    
    # check image defined
    image_metadata_repository.find_by_repo(container_metadata.repo, tag: container_metadata.tag)

    container = docker_api.create_container(container_metadata)
    
    container_metadata.container_id = container.id

    container
  end
end