class Indocker::ContainerRunnerService 
  def run(container_name, image_name)
    container = Indocker.containers.detect {|container| container.name == container_name}
    raise Indocker::Errors::ContainerDoesNotDefined if container.nil?

    container_id = Indocker::DockerCommands.new.run_container(container.name, container.from)
    container.id = container_id
  end
end