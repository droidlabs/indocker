class Indocker::ContainerRunnerService 
  def run(container_name)
    container = Indocker.containers.detect {|container| container.name == container_name}
    raise Indocker::Errors::ContainerDoesNotDefined if container.nil?

    image = Indocker.images.detect {|image| image.name == container.from}
    raise Indocker::Errors::ImageForContainerDoesNotExist if image.nil?
    debugger
    container_id = Indocker::DockerCommands.new.run_container(container.name, image.name)
    container.id = container_id
  end
end