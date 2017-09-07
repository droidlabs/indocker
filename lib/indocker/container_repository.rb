class Indocker::ContainerRepository
  include SmartIoC::Iocify
  
  bean :container_repository

  def get_container(container_name)
    container = Indocker.containers.detect {|container| container.name == container_name}
    raise Indocker::Errors::ContainerDoesNotDefined if container.nil?

    container
  end
end