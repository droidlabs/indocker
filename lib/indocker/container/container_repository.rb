class Indocker::ContainerRepository
  include SmartIoC::Iocify
  
  bean :container_repository

  def get_container(container_name)
    container = Indocker.containers.detect {|container| container.name == container_name}
    raise Indocker::Errors::ContainerIsNotDefined if container.nil?

    container
  end
end