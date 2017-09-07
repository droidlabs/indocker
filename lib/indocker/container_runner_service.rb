class Indocker::ContainerRunnerService 
  include SmartIoC::Iocify
  
  bean   :container_runner_service
  inject :image_repository
  inject :container_repository
  inject :docker_commands

  def run(container_name)
    container = container_repository.get_container(container_name)

    image = image_repository.get_image(container.from)
    
    container_id = docker_commands.run_container(container.name, image.name)
    container.id = container_id
  end
end