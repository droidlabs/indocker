class Indocker::ContainerRunnerService 
  include SmartIoC::Iocify
  
  bean   :container_runner_service
  inject :image_repository
  inject :container_repository
  inject :docker_api

  def create(container_name)
    container_metadata = container_repository.get_container(container_name)
    
    # check image exists
    image_repository.find_by_repo(container_metadata.repo, tag: container_metadata.tag)

    container = docker_api.create_container(container_metadata)
    container_metadata.container_id = container.id

    container
  end
end